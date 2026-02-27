---
name: pt-planning-recon
description: Defines penetration test scope and performs authorized reconnaissance using passive and active methods. Use when planning a test engagement, collecting target intelligence, building asset inventories, or preparing recon findings.
---

# Pen Test Planning and Reconnaissance

## Authorized Use Only

Use this skill only for systems explicitly authorized in writing by the user. If authorization or scope is unclear, pause and ask for confirmation before any target interaction.

## Objectives

1. Define engagement boundaries and success criteria.
2. Build an asset inventory from approved sources.
3. Perform passive recon first, then scoped active recon.
4. Produce recon outputs that feed scanning and exploitation phases.

## Workflow

1. Confirm rules of engagement:
   - In-scope and out-of-scope assets
   - Allowed test windows and rate limits
   - Prohibited actions (DoS, credential stuffing, social engineering, etc.)
2. Collect passive intelligence:
   - Domains, subdomains, ASN/IP ranges, DNS, mail records, public endpoints
   - Technology stack indicators and externally visible services
3. Plan active recon in scope:
   - Host discovery and service fingerprinting with safe defaults
   - Logging of every command, timestamp, and target touched
4. Normalize findings:
   - Deduplicate assets and map to owners/business function when known
   - Tag confidence level and evidence source
5. Handoff artifacts:
   - Asset inventory for scanning
   - Initial threat hypotheses and likely attack paths

## Output Template

Use this structure for recon deliverables:

```markdown
# Planning and Recon Output

## Scope Summary
- In scope:
- Out of scope:
- Test window:
- Constraints:

## Asset Inventory
- Asset:
  - Type:
  - Exposure:
  - Evidence:

## Recon Findings
- Finding:
  - Evidence:
  - Potential risk:
  - Next step:

## Handoff to Scanning
- Prioritized targets:
- Recommended scan strategy:
```

## Quality Checks

- Scope constraints are explicit and referenced in findings.
- No unapproved targets were queried.
- Evidence is reproducible and timestamped.
- Findings are prioritized by likely business impact.
