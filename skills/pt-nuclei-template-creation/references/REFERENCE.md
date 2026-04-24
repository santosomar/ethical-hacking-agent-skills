# Nuclei Template Reference

Detailed reference for matchers, extractors, DSL, and template variables.
Load this file when the concise examples in SKILL.md are insufficient.

---

## Template Variables (Built-in)

| Variable | Description | Example value |
|---|---|---|
| `{{BaseURL}}` | Full base URL (scheme + host + port) | `https://example.com:8443` |
| `{{RootURL}}` | Scheme + host only (no path) | `https://example.com` |
| `{{Hostname}}` | Host + port | `example.com:8443` |
| `{{Host}}` | Hostname only | `example.com` |
| `{{Port}}` | Port number | `8443` |
| `{{Path}}` | URL path | `/api/v1` |
| `{{File}}` | Filename in path | `index.php` |
| `{{Scheme}}` | URL scheme | `https` |
| `{{FQDN}}` | Fully qualified domain name | `example.com` |

---

## Matcher Types

### `status`

Matches integer HTTP status codes.

```yaml
matchers:
  - type: status
    status:
      - 200
      - 301
```

### `word`

Matches literal strings. Default `condition` is `or`; use `and` to require all words.

```yaml
matchers:
  - type: word
    part: body          # body | header | all | interactsh_protocol
    words:
      - "root:x:0:0"
      - "/bin/bash"
    condition: and
```

Hex-encoded words are also supported:

```yaml
matchers:
  - type: word
    encoding: hex
    words:
      - "504b0304"      # ZIP magic bytes
    part: body
```

### `regex`

```yaml
matchers:
  - type: regex
    part: body
    regex:
      - '(?i)phpinfo\(\)'
      - 'PHP Version [0-9.]+'
    condition: or
```

### `binary`

Matches raw hex sequences in binary responses.

```yaml
matchers:
  - type: binary
    binary:
      - "504B0304"       # ZIP
      - "FFD8FFE0"       # JPEG
    condition: or
    part: body
```

### `size`

Matches on content length.

```yaml
matchers:
  - type: size
    size:
      - 0               # empty response
```

### `dsl`

Arbitrary boolean expressions using helper functions. The most flexible matcher.

```yaml
matchers:
  - type: dsl
    dsl:
      - "status_code == 200 && contains(body, 'secret')"
      - "len(body) > 500 && regex(body, '[0-9]{4}-[0-9]{4}')"
    condition: or
```

### `xpath`

Matches HTML/XML using XPath queries. Fires if the query returns any nodes.

```yaml
matchers:
  - type: xpath
    part: body
    xpath:
      - "//title[contains(text(),'Admin')]"
```

---

## Matcher Options

| Key | Values | Default | Notes |
|---|---|---|---|
| `part` | `body`, `header`, `all`, `raw`, `interactsh_protocol` | `body` | What to match against |
| `condition` | `and`, `or` | `or` | Logic between items in the same matcher |
| `matchers-condition` | `and`, `or` | `or` | Logic between multiple matchers |
| `negative` | `true`, `false` | `false` | Invert the match result |
| `internal` | `true`, `false` | `false` | Suppress output; use as gate in `flow:` |
| `name` | string | — | Label shown in output for multi-matcher templates |
| `encoding` | `hex` | — | Decode hex-encoded word values before matching |

### DSL Response Parts

| Expression | Description |
|---|---|
| `status_code` | HTTP status integer |
| `content_length` | Content-Length header value |
| `body` | Response body string |
| `all_headers` | All headers concatenated |
| `header_name` | Any header, lowercased, dashes→underscores (e.g. `x_powered_by`) |
| `raw` | Headers + body |
| `duration` | Response time in seconds (float) |
| `redirects` | Number of redirects followed |

---

## DSL Helper Functions (selection)

### String

| Function | Example |
|---|---|
| `contains(str, substr)` | `contains(body, "admin")` |
| `startsWith(str, prefix)` | `startsWith(body, "<!DOCTYPE")` |
| `endsWith(str, suffix)` | `endsWith(header, "json")` |
| `len(str)` | `len(body) > 1024` |
| `toupper(str)` | `contains(toupper(body), "ERROR")` |
| `tolower(str)` | `tolower(all_headers)` |
| `replace(str, old, new)` | `replace(body, " ", "")` |
| `regex(str, pattern)` | `regex(body, "[0-9]{6}")` |
| `split(str, sep, idx)` | `split(body, ":", 1)` |
| `trim(str)` | `trim(body)` |
| `trimSpace(str)` | `trimSpace(body)` |
| `count(str, substr)` | `count(body, "error") > 3` |
| `substr(str, start, end)` | `substr(body, 0, 10)` |

### Encoding / Hashing

| Function | Example |
|---|---|
| `base64(str)` | `base64("admin:admin")` |
| `base64Decode(str)` | `base64Decode(token)` |
| `urlEncode(str)` | `urlEncode("a b")` |
| `urlDecode(str)` | `urlDecode(param)` |
| `hexEncode(str)` | `hexEncode("ABC")` |
| `hexDecode(str)` | `hexDecode("414243")` |
| `md5(str)` | `md5(body)` |
| `sha1(str)` | `sha1(body)` |
| `sha256(str)` | `sha256(token)` |

### Random / Generation

| Function | Example |
|---|---|
| `rand_int(min, max)` | `rand_int(1000, 9999)` |
| `rand_text_alpha(n)` | `rand_text_alpha(8)` |
| `rand_text_alphanumeric(n)` | `rand_text_alphanumeric(16)` |
| `rand_text_numeric(n)` | `rand_text_numeric(6)` |
| `generate_java_gadget(gadget, cmd, enc)` | See Nuclei docs |

### Time

| Function | Example |
|---|---|
| `unix_time()` | `not_after < unix_time()` (SSL cert expired) |
| `date_time(format)` | `date_time("2006-01-02")` |

### Network / Misc

| Function | Example |
|---|---|
| `ip(host)` | `ip("example.com")` |
| `cidr(ip, range)` | `cidr(ip(host), "10.0.0.0/8")` |
| `compare_versions(v, constraints)` | `compare_versions(version, ">= 1.0, < 2.0")` |
| `print_debug(vals...)` | Debug only — prints to stdout |

---

## Extractor Types

### `regex`

```yaml
extractors:
  - type: regex
    part: body
    name: version
    group: 1            # capture group index (0 = full match)
    regex:
      - 'Version[:\s]+([0-9]+\.[0-9]+\.[0-9]+)'
```

### `kval`

Extracts from `key: value` or `key=value` pairs in headers/cookies. Replace `-` with `_`.

```yaml
extractors:
  - type: kval
    kval:
      - x_powered_by
      - set_cookie
```

### `json`

JQ-like syntax for JSON response bodies.

```yaml
extractors:
  - type: json
    part: body
    name: token
    json:
      - '.access_token'
      - '.data.items[] | .id'
```

### `xpath`

```yaml
extractors:
  - type: xpath
    part: body
    attribute: href          # optional: extract an attribute rather than text content
    xpath:
      - '//a[@class="download"]'
```

### `dsl`

```yaml
extractors:
  - type: dsl
    dsl:
      - 'substr(body, 0, 200)'
      - '"Status: " + to_string(status_code)'
```

### Extractor Options

| Key | Notes |
|---|---|
| `internal: true` | Store value as a variable for use in later requests; suppress output |
| `name` | Variable name used in subsequent requests via `{{name}}` |
| `group` | Regex capture group index (default 0 = full match) |
| `part` | `body`, `header`, `all`, `raw` |

---

## Multi-Request Variable Passing

Extract in request 1, use in request 2:

```yaml
http:
  - raw:
      - |
        GET /login HTTP/1.1
        Host: {{Hostname}}

    extractors:
      - type: regex
        name: csrf
        part: body
        internal: true
        group: 1
        regex:
          - 'csrf_token" value="([a-f0-9]{32})"'

      - |
        POST /login HTTP/1.1
        Host: {{Hostname}}
        Content-Type: application/x-www-form-urlencoded

        username=admin&password=admin&csrf_token={{csrf}}
```

---

## Interactsh (Out-of-Band)

Use `{{interactsh-url}}` as the payload. Nuclei registers the callback and confirms interaction.

```yaml
http:
  - method: GET
    path:
      - '{{BaseURL}}/redirect?url=http://{{interactsh-url}}'

    matchers:
      - type: word
        part: interactsh_protocol
        words:
          - "http"
```

Requires network access to `interact.sh` (or a self-hosted interactsh server via `-iserver`).
