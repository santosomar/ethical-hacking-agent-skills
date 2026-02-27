---
name: pt-fuzzing-web-api
description: Performs authorized fuzzing of web applications and APIs to discover input validation failures, parser bugs, and stability issues. Use when testing HTTP endpoints, request parameters, payload handling, and error behavior under malformed or unexpected inputs.
---

# Web and API Fuzzing

## Authorized Use Only

Run fuzzing only against explicitly approved targets and test environments. Respect rate limits, test windows, and service stability constraints. Pause immediately if production impact risk increases.

## Objectives

1. Find input-handling vulnerabilities and crash conditions.
2. Identify unexpected responses, parser failures, and auth boundary issues.
3. Produce reproducible cases and actionable remediation guidance.

## Workflow

1. Define scope and safety guardrails:
   - In-scope endpoints, methods, and auth contexts
   - Allowed request volume, concurrency, and timeout ceilings
   - Stop conditions for instability or data risk
2. Build fuzzing plan:
   - Parameter inventory (query, path, headers, body, file uploads)
   - Baseline valid requests for each endpoint
   - Mutation strategy (length, encoding, type confusion, schema violations)
3. Execute controlled fuzzing:
   - Start low-and-slow, then increase breadth
   - Track status code anomalies, latency spikes, crashes, and WAF behavior
   - Preserve minimal failing payloads and request metadata
4. Validate and triage:
   - Reproduce findings with reduced payloads
   - Separate true defects from expected validation failures
5. Recommend fixes:
   - Input/schema validation hardening
   - Parser/library updates and safer defaults
   - Regression tests for discovered cases

## Output Template

```markdown
# Web/API Fuzzing Output

## Scope and Configuration
- Targets:
- Auth context:
- Rate/concurrency limits:
- Stop conditions:

## Findings
- Finding:
  - Endpoint:
  - Trigger input:
  - Observed behavior:
  - Repro steps:
  - Security/availability impact:
  - Recommended fix:

## Stability and Detection Notes
- Availability effects:
- Alerting/monitoring observations:

## Regression Test Cases
- Case:
  - Expected safe behavior:
```

## Quality Checks

- Findings are reproducible with minimized payloads.
- Evidence includes exact request/response context.
- Recommendations include prevention and regression coverage.
