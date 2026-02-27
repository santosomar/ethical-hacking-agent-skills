---
name: pt-scanning
description: Performs authorized security scanning using static, dynamic, and vulnerability-focused methods. Use when mapping exposed services, profiling application behavior, and identifying known weaknesses for validation.
---

# Pen Test Scanning

## Authorized Use Only

Run scans only against approved in-scope targets and within agreed timing/rate constraints. If scan aggressiveness is unknown, default to conservative settings and ask.

## Objectives

1. Characterize reachable hosts, ports, services, and tech stack.
2. Identify likely vulnerabilities with low false positives.
3. Prioritize findings for manual validation in later phases.

## Workflow

1. Prepare scan plan:
   - Inputs: recon asset list, scope, constraints
   - Segment scans by asset class (web, API, infra, device)
2. Run discovery and service profiling:
   - Host/port/service enumeration with safe rate limits
   - Capture versions and configuration indicators
3. Perform vulnerability scanning:
   - Focus on known CVEs, weak configs, and exposed management interfaces
   - Record scanner confidence and evidence, not just severity labels
4. Application-focused scanning:
   - Static review when source or binaries are available
   - Dynamic analysis for runtime behavior and attack surface
5. Triage results:
   - Remove duplicates
   - Flag likely false positives for manual verification
   - Rank by exploitability and business impact

## Output Template

```markdown
# Scanning Output

## Scan Coverage
- Target groups:
- Methods used:
- Time window:

## Findings (Prioritized)
- Finding:
  - Affected asset:
  - Evidence:
  - Confidence:
  - Exploitability notes:
  - Recommended validation:

## False Positive Queue
- Candidate:
  - Why uncertain:
  - Verification step:

## Handoff to Gaining Access
- High-priority validated candidates:
- Preconditions:
```

## Quality Checks

- Coverage is mapped to scope; gaps are documented.
- Every finding includes evidence and confidence.
- Results are deduplicated and prioritized for manual testing.
