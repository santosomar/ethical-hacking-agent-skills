---
name: pt-analysis-reporting
description: Produces penetration test reports with executive summary, technical findings, and remediation guidance. Use when consolidating test evidence, prioritizing risk, and preparing stakeholder-ready deliverables.
---

# Pen Test Analysis and Reporting

## Objectives

1. Translate technical outcomes into business risk.
2. Provide reproducible technical detail for remediation teams.
3. Deliver prioritized, actionable fixes with retest criteria.

## Workflow

1. Consolidate evidence:
   - Gather outputs from recon, scanning, exploitation, and persistence testing
   - Normalize severity/risk ratings and remove duplicates
2. Build executive narrative:
   - Overall security posture
   - Top risks and likely business impact
   - Immediate leadership actions
3. Build technical findings:
   - One finding per vulnerability or attack path
   - Include evidence, reproduction path, and affected assets
4. Define remediation plan:
   - Tactical fixes (short term)
   - Structural improvements (long term)
   - Ownership and retest requirements
5. Final QA:
   - Validate evidence links
   - Ensure claims are supportable and scope-accurate

## Report Template

```markdown
# Penetration Test Report

## Executive Summary
- Overall risk posture:
- Highest-priority risks:
- Recommended executive actions:

## Methodology and Scope
- Scope:
- Test windows:
- Constraints:
- Stages performed:

## Technical Findings
### Finding: [Title]
- Severity:
- Affected assets:
- Evidence:
- Reproduction summary:
- Impact:
- Remediation:
- Retest steps:

## Prioritized Remediation Roadmap
1. [Action] - Owner - Target date
2. [Action] - Owner - Target date

## Appendix
- Tools and versions:
- Evidence inventory:
```

## Quality Checks

- Every finding maps to evidence and scope.
- Remediation is specific, testable, and owned.
- Executive summary avoids jargon and states business risk clearly.
