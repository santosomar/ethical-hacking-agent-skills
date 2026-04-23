# Protocol Reference

Complete option reference for every Nuclei protocol block.

---

## HTTP Protocol

### Simple request

```yaml
http:
  - method: GET | POST | PUT | DELETE | PATCH | OPTIONS | HEAD
    path:
      - "{{BaseURL}}/path"
    headers:
      X-Custom-Header: value
    body: '{"key":"value"}'
```

### HTTP options

| Key | Type | Notes |
|---|---|---|
| `method` | string | HTTP verb |
| `path` | list | One request per path; supports template variables |
| `headers` | map | Additional request headers |
| `body` | string | Request body |
| `raw` | list | Raw HTTP/1.1 strings (precise wire control) |
| `redirects` | bool | Follow redirects (default false) |
| `max-redirects` | int | Max redirects to follow (default 10) |
| `pipeline` | bool | HTTP pipelining |
| `unsafe` | bool | Disable Go's HTTP client normalization (raw byte injection) |
| `race` | bool | Send all requests simultaneously |
| `race-count` | int | Number of concurrent race requests |
| `req-condition` | bool | Expose `req_` variables for request matching |
| `stop-at-first-match` | bool | Stop after first positive match |
| `cookie-reuse` | bool | Reuse cookies across requests in the block |
| `read-all` | bool | Read the full response even after match |
| `max-size` | int | Maximum response body size in bytes |
| `iterate-all` | bool | Iterate over all values from a list extractor |
| `digest-username` | string | HTTP Digest Auth username |
| `digest-password` | string | HTTP Digest Auth password |
| `disable-path-automerge` | bool | Prevent BaseURL path from being merged |
| `fuzzing` | list | OpenAPI / path fuzzing rules |

### Payloads + attack types

```yaml
http:
  - method: POST
    path:
      - "{{BaseURL}}/login"
    body: "username={{user}}&password={{pass}}"
    attack: pitchfork        # batteringram | pitchfork | clusterbomb
    payloads:
      user:
        - admin
        - root
      pass:
        - admin
        - toor
```

| Attack type | Behaviour |
|---|---|
| `batteringram` | Same payload in all positions simultaneously |
| `pitchfork` | Parallel iteration — list[0] together, list[1] together, … |
| `clusterbomb` | Cartesian product of all lists |

### Raw request

```yaml
http:
  - raw:
      - |
        GET /<?php echo md5(1337); ?> HTTP/1.1
        Host: {{Hostname}}
        Connection: close
    unsafe: true    # skip normalisation so the payload reaches the wire unchanged
```

---

## DNS Protocol

```yaml
dns:
  - name: "{{FQDN}}"
    type: A | AAAA | CNAME | MX | NS | TXT | PTR | SOA | CAA
    class: inet              # inet (default)
    retries: 2
    recursion: true
    resolvers:
      - "8.8.8.8"
    matchers:
      - type: word
        part: answer | authority | additional | raw
        words:
          - "s3.amazonaws.com"
```

### DNS response parts

| Part | Contents |
|---|---|
| `answer` | Answer section |
| `authority` | Authority section |
| `additional` | Additional section |
| `raw` | Full raw DNS response |

---

## TCP Protocol

```yaml
tcp:
  - address:
      - "{{Host}}:{{Port}}"
    inputs:
      - data: "HELLO\r\n"    # string sent on connect
        read: 1024           # bytes to read after sending
      - data: "QUIT\r\n"
    read-size: 2048          # default read size
    read-all: false
    tls: false               # wrap connection in TLS
    matchers:
      - type: word
        part: body
        words:
          - "220 "           # SMTP banner
```

---

## SSL Protocol

```yaml
ssl:
  - address: "{{Host}}:{{Port}}"
    min-version: tls10       # tls10 | tls11 | tls12 | tls13
    max-version: tls13
    cipher-suites:
      - TLS_AES_128_GCM_SHA256
    matchers:
      - type: dsl
        dsl:
          - 'not_after < unix_time()'             # certificate expired
          - 'contains(subject_cn, "staging")'     # accidental prod exposure
          - 'sha1_fingerprint == "aa:bb:..."'     # known bad cert
```

### SSL DSL variables

| Variable | Description |
|---|---|
| `subject_cn` | Common Name |
| `subject_an` | Subject Alternative Names (string) |
| `subject_org` | Organization |
| `issuer_cn` | Issuer CN |
| `issuer_org` | Issuer Org |
| `not_before` | Unix timestamp — cert valid from |
| `not_after` | Unix timestamp — cert expires |
| `serial` | Serial number |
| `sha1_fingerprint` | SHA-1 fingerprint |
| `sha256_fingerprint` | SHA-256 fingerprint |
| `tls_version` | Negotiated TLS version string |
| `cipher` | Negotiated cipher suite |

---

## Headless (Browser) Protocol

Use only when JavaScript rendering is required. Significantly slower than `http:`.

```yaml
headless:
  - steps:
      - action: navigate
        args:
          url: "{{BaseURL}}"

      - action: waitload          # wait for DOMContentLoaded

      - action: click
        args:
          by: xpath
          xpath: '//button[@id="login"]'

      - action: type
        args:
          by: xpath
          xpath: '//input[@name="username"]'
          value: "admin"

      - action: screenshot        # saves to output

      - action: script
        args:
          code: "document.title"  # returns value to extractor
        name: page_title

    matchers:
      - type: word
        part: body
        words:
          - "Dashboard"
```

### Headless actions

| Action | Key args | Notes |
|---|---|---|
| `navigate` | `url` | Load URL |
| `waitload` | — | Wait for page load |
| `click` | `by`, `xpath`/`selector` | Click element |
| `rightclick` | `by`, `xpath`/`selector` | Right-click |
| `type` | `by`, `xpath`/`selector`, `value` | Type into input |
| `select` | `by`, `xpath`/`selector`, `value` | Select `<option>` |
| `files` | `by`, `xpath`/`selector`, `value` | File upload |
| `screenshot` | — | Capture full page |
| `script` | `code`, `name` | Execute JS; result stored in `name` |
| `sleep` | `duration` | Pause (seconds) |
| `waitforselector` | `by`, `xpath`/`selector` | Wait until element visible |
| `addheader` | `name`, `value` | Inject request header |
| `setheader` | `name`, `value` | Override request header |
| `deleteheader` | `name` | Remove request header |
| `setcookie` | `name`, `value` | Set cookie |
| `deletecookie` | `name` | Remove cookie |
| `keyboard` | `action`, `key` | Keyboard event |

---

## File Protocol

Scans local filesystem paths. Used for finding secrets or misconfigs in source trees.

```yaml
file:
  - path:
      - "{{scandir}}"           # target directory (supplied via -target flag)
    extensions:
      - yaml
      - yml
      - json
    denylist:
      - ".git"
      - "node_modules"
    matchers:
      - type: regex
        part: raw
        regex:
          - 'api[_-]?key\s*[:=]\s*["\x27]?[A-Za-z0-9]{20,}'
          - '-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----'
```

---

## JavaScript Protocol

Execute custom JS inside the Nuclei runtime for complex, stateful checks.

```yaml
javascript:
  - code: |
      const res = template.http_get(Host + "/api/check");
      if (res.status === 200 && res.body.includes("admin")) {
        return { matched: true, extracted: res.body };
      }
      return { matched: false };
    args:
      Host: "{{BaseURL}}"
    matchers:
      - type: dsl
        dsl:
          - "matched == true"
    extractors:
      - type: dsl
        dsl:
          - "extracted"
```

---

## Workflow (multi-template orchestration)

Workflows chain templates and conditionally run follow-up checks.

```yaml
# workflow.yaml
id: wordpress-full-audit

info:
  name: WordPress Full Audit
  author: your-handle
  severity: info

workflows:
  - template: http/technologies/wordpress-detect.yaml
    matchers:
      - name: WordPress
        subtemplates:
          - template: http/cves/wordpress/
          - template: http/exposures/wordpress/
```

---

## `flow:` (intra-template orchestration)

Controls request execution order within a single template using JS boolean expressions.

```yaml
flow: http(1) && http(2)            # run request 2 only if request 1 matched
flow: dns(1) && http(1)             # cross-protocol gate
flow: http(1) || http(2)            # run request 2 if request 1 did NOT match
```

Protocols are referenced by name and 1-based index.
Multiple protocol blocks can each have a `flow:` expression.
