---
name: pt-nuclei-template-creation
description: Creates Nuclei YAML templates for vulnerability detection across HTTP, DNS, TCP, SSL, and other protocols. Use when converting a confirmed vulnerability, misconfiguration, or exposure into a reusable automated check — for example, turning a manual finding into a detection rule, writing a CVE check, or codifying a technology fingerprint.
compatibility: Requires nuclei (github.com/projectdiscovery/nuclei) v3+ installed and reachable on PATH.
metadata:
  author: ethical-hacking-agent-skills
  version: "2.0"
allowed-tools: Bash(nuclei:*) Read Write
---

# Nuclei Template Creation

## Authorized Use Only

Run generated templates only against targets explicitly in scope. Templates that send payloads (SSRF callbacks, command injection probes, authentication attempts) must respect the same rules of engagement as manual testing. Validate on an approved test host before scanning production.

## Objectives

1. Convert a confirmed finding into a YAML template with low-to-zero false positives.
2. Produce a template that validates against the official JSON schema and passes `nuclei -validate`.
3. Document severity, remediation, and references so the template is report-ready.
4. Minimize request count and avoid destructive payloads.

## Workflow

1. Gather inputs:
   - Exact request that triggers the condition (method, path, headers, body)
   - Exact response signal that confirms it (status, body string, header, timing)
   - CVE/CWE IDs, vendor, product, affected versions, references
   - Severity justification (CVSS or business-impact rationale)
2. Choose protocol and request style:
   - `http:` with `method` + `path` for simple GET/POST checks
   - `http:` with `raw:` for precise control (custom headers, malformed requests, multi-step auth)
   - `dns:`, `ssl:`, `tcp:`, `javascript:` for non-HTTP targets
   - Never use the deprecated `requests:` key — always `http:`
3. Build matchers for the narrowest reliable signal:
   - Prefer `matchers-condition: and` combining status + body/header evidence
   - Use `type: word` for literal strings, `type: regex` only when patterns vary
   - Use `type: dsl` for cross-field logic (e.g. `status_code == 200 && contains(body, "x")`)
   - Set `part:` explicitly (`body`, `header`, `all`) — do not rely on defaults when precision matters
   - Add `negative: true` matchers to exclude known false-positive pages
4. Add extractors only if output is needed:
   - `regex` with `group:` for version numbers or tokens
   - `kval` for response headers
   - Mark `internal: true` if the value feeds a later request rather than report output
5. Self-review against the quality checks below, then validate.

## Template Skeleton

Use this as the starting structure. Remove unused blocks — do not leave empty keys.

```yaml
id: vendor-product-issue-type

info:
  name: Vendor Product — Issue Summary
  author: your-handle
  severity: info|low|medium|high|critical
  description: |
    One or two sentences describing what is detected and why it matters.
  remediation: |
    Specific fix action (patch version, config change, etc.).
  reference:
    - https://vendor.example/advisory
    - https://nvd.nist.gov/vuln/detail/CVE-XXXX-YYYYY
  classification:
    cve-id: CVE-XXXX-YYYYY
    cwe-id: CWE-NN
  metadata:
    verified: true
    max-request: 1
    vendor: vendor-name
    product: product-name
  tags: cve,cve2025,rce,vendor-name

http:
  - method: GET
    path:
      - "{{BaseURL}}/path/to/check"

    matchers-condition: and
    matchers:
      - type: status
        status:
          - 200

      - type: word
        part: body
        words:
          - "unique-string-confirming-vuln"
        condition: and

    extractors:
      - type: regex
        part: body
        group: 1
        regex:
          - 'version["\s:]+([0-9.]+)'
```

## Raw Request Form

Use when you need exact wire-level control (multi-step, auth chains, non-standard formatting):

```yaml
http:
  - raw:
      - |
        POST /api/login HTTP/1.1
        Host: {{Hostname}}
        Content-Type: application/json

        {"user":"{{username}}","pass":"{{password}}"}

      - |
        GET /api/admin HTTP/1.1
        Host: {{Hostname}}
        Cookie: {{session}}

    cookie-reuse: true

    extractors:
      - type: regex
        name: session
        part: header
        internal: true
        regex:
          - 'Set-Cookie: (session=[a-f0-9]+)'

    matchers:
      - type: word
        part: body_2
        words:
          - "admin_dashboard"
```

Suffix response parts with `_N` (1-indexed) to match against a specific request in a multi-request chain.

## Non-HTTP Protocols

### DNS

```yaml
dns:
  - name: "{{FQDN}}"
    type: CNAME
    matchers:
      - type: word
        words:
          - "s3.amazonaws.com"
        part: answer
```

### TCP / SSL

```yaml
tcp:
  - address:
      - "{{Host}}:{{Port}}"
    inputs:
      - data: "\r\n"
    read-size: 2048
    matchers:
      - type: word
        part: body
        words:
          - "OpenSSH"

ssl:
  - address: "{{Host}}:{{Port}}"
    matchers:
      - type: dsl
        dsl:
          - 'contains(subject_cn, "internal.corp")'
          - 'not_after < unix_time()'     # expired cert
        condition: or
```

### Headless (Browser)

```yaml
headless:
  - steps:
      - action: navigate
        args:
          url: "{{BaseURL}}/login"
      - action: waitload
    matchers:
      - type: word
        part: body
        words:
          - "admin panel"
```

Use `headless:` only when JavaScript rendering is required; it is much slower than `http:`.

## Variables and Payloads

Use a `variables:` block to precompute values:

```yaml
variables:
  encoded: "{{base64('admin:admin')}}"

http:
  - method: GET
    path:
      - "{{BaseURL}}/api/v1/secret"
    headers:
      Authorization: "Basic {{encoded}}"
```

Use `payloads:` with an attack type for fuzzing checks:

```yaml
http:
  - method: POST
    path:
      - "{{BaseURL}}/search"
    body: "q={{payload}}"
    payloads:
      payload:
        - "' OR 1=1--"
        - "\" OR 1=1--"
    attack: batteringram          # one payload at a time; use clusterbomb for combos
    matchers:
      - type: word
        words:
          - "SQL syntax"
        part: body
```

Attack types: `batteringram` (single list, same value per position), `pitchfork` (parallel lists), `clusterbomb` (cartesian product).

## Flow Control

Use `flow:` to orchestrate multi-protocol or conditional request chains. Requests only run when the preceding gate returns true.

```yaml
flow: http(1) && http(2)

http:
  - method: GET
    path:
      - "{{BaseURL}}/wp-content/plugins/vuln-plugin/readme.txt"
    matchers:
      - type: word
        words: ["Vuln Plugin"]
        internal: true             # gate check — suppresses output

  - method: POST
    path:
      - "{{BaseURL}}/wp-admin/admin-ajax.php"
    body: "action=exploit"
    matchers:
      - type: word
        words: ["success"]
```

## Output Template

```markdown
# Nuclei Template: {{id}}

## Template summary
- File: `{{id}}.yaml`
- Protocol: http | dns | tcp | ssl | headless
- Severity: info | low | medium | high | critical
- Request count: N

## Detection logic
- Trigger path/condition:
- Matcher signals:
  1.
  2.
- Extractors (if any):

## Validation results
- `nuclei -validate`: pass | fail (list errors)
- True-positive host tested: yes | no
- True-negative host tested: yes | no
- False-positive risk notes:

## Handoff to pt-scanning
- Template path for inclusion in scan runs:
- Recommended tags/filters: `-tags`
- Any prerequisites (auth creds, interactsh server, etc.):
```

## Validation

Use the bundled script for combined schema + lint checking:

```bash
# Validate a single template (schema + lint)
bash scripts/validate.sh ./template.yaml

# Validate + dry-run against an approved host
bash scripts/validate.sh ./template.yaml -u https://approved-test-host

# Validate all templates in a directory
bash scripts/validate.sh ./templates/
```

Or run nuclei directly:

```bash
nuclei -t ./template.yaml -validate
nuclei -t ./template.yaml -u https://approved-test-host -debug
```

## Reference Material

Load these files on demand when more depth is needed:

- **[references/REFERENCE.md](references/REFERENCE.md)** — complete DSL helper functions, all matcher/extractor types, template variables, and response-part table
- **[references/protocols.md](references/protocols.md)** — full option reference for HTTP, DNS, TCP, SSL, Headless, File, and JavaScript protocols
- **[assets/cve-http.yaml](assets/cve-http.yaml)** — annotated CVE detection template (copy and adapt)
- **[assets/tech-fingerprint.yaml](assets/tech-fingerprint.yaml)** — technology fingerprinting template
- **[assets/subdomain-takeover.yaml](assets/subdomain-takeover.yaml)** — DNS subdomain takeover detection template

Upstream reference (authoritative):

- Syntax reference: `github.com/projectdiscovery/nuclei/blob/dev/SYNTAX-REFERENCE.md`
- JSON schema: `github.com/projectdiscovery/nuclei/blob/dev/nuclei-jsonschema.json`
- Community templates: `github.com/projectdiscovery/nuclei-templates`

## Quality Checks

- `id` is lowercase, hyphen-separated, and describes vendor + issue (no spaces, no generic names like `test` or `vuln`).
- `info.severity` is justified — `critical`/`high` only for confirmed RCE, auth bypass, or direct data exposure.
- `metadata.max-request` matches the actual number of requests the template sends.
- Matchers require at least two independent signals (e.g. status AND body) unless a single signal is provably unique.
- No `requests:` key (deprecated) — uses `http:` instead.
- Template passes `nuclei -validate` with no warnings.
- Template was run against one known-vulnerable and one known-clean host to confirm true-positive and true-negative behavior.
- Payloads are non-destructive: no file writes, no account creation, no state mutation unless explicitly approved and documented in `description`.
