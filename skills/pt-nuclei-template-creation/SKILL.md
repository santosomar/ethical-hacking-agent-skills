---
name: pt-nuclei-template-creation
description: Creates Nuclei YAML templates for vulnerability detection across HTTP, DNS, TCP, SSL, and other protocols. Use when converting a confirmed vulnerability, misconfiguration, or exposure into a reusable automated check — for example, turning a manual finding into a detection rule, writing a CVE check, or codifying a technology fingerprint.
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

## Validation

```bash
# Schema + syntax check (no network)
nuclei -t ./template.yaml -validate

# Dry run against an approved host with full request/response debug
nuclei -t ./template.yaml -u https://approved-test-host -debug

# Lint against the official JSON schema (optional, for editor integration)
# https://raw.githubusercontent.com/projectdiscovery/nuclei/dev/nuclei-jsonschema.json
```

## Reference Material

When a field or matcher type is unclear, consult in this order:

1. Auto-generated syntax reference: `github.com/projectdiscovery/nuclei/blob/dev/SYNTAX-REFERENCE.md`
2. JSON schema (exhaustive field list): `github.com/projectdiscovery/nuclei/blob/dev/nuclei-jsonschema.json`
3. Real examples by category: `github.com/projectdiscovery/nuclei-templates/tree/main/http`
4. Matcher reference: `docs.projectdiscovery.io/templates/reference/matchers`

## Quality Checks

- `id` is lowercase, hyphen-separated, and describes vendor + issue (no spaces, no generic names like `test` or `vuln`).
- `info.severity` is justified — `critical`/`high` only for confirmed RCE, auth bypass, or direct data exposure.
- `metadata.max-request` matches the actual number of requests the template sends.
- Matchers require at least two independent signals (e.g. status AND body) unless a single signal is provably unique.
- No `requests:` key (deprecated) — uses `http:` instead.
- Template passes `nuclei -validate` with no warnings.
- Template was run against one known-vulnerable and one known-clean host to confirm true-positive and true-negative behavior.
- Payloads are non-destructive: no file writes, no account creation, no state mutation unless explicitly approved and documented in `description`.
