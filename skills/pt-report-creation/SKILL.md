---
name: pt-report-creation
description: Creates penetration test deliverables for executive and technical audiences, including prioritized findings and remediation plans. Use when drafting, structuring, or finalizing pen test reports from collected evidence.
---

# Pen Test Report Creation

## Objectives

1. Convert assessment evidence into clear stakeholder-ready reporting.
2. Provide technical depth for remediation teams and concise risk framing for leadership.
3. Produce actionable remediation and retest guidance.

## Workflow

1. Collect and normalize evidence:
   - Consolidate outputs from all test phases
   - Deduplicate related findings and validate source evidence
2. Draft executive section:
   - Overall risk posture and top business risks
   - Key decisions and immediate actions for leadership
3. Draft technical findings:
   - One finding per issue or exploit chain
   - Include affected assets, reproduction summary, impact, and fixes
4. Build remediation roadmap:
   - Prioritize by exploitability and business impact
   - Assign owner, timeline, and verification criteria
5. Final QA pass:
   - Verify clarity, evidence traceability, and scope alignment
   - Remove ambiguity and unsupported claims

## Report Template

```markdown
# Penetration Test Report

## Executive Summary
- Overall security posture:
- Top business risks:
- Immediate leadership actions:

## Scope and Methodology
- In scope:
- Out of scope:
- Test windows and constraints:
- Method summary:

## Findings
### [Finding Title]
- Severity:
- Affected assets:
- Evidence:
- Reproduction summary:
- Technical impact:
- Business impact:
- Remediation:
- Retest criteria:

## Prioritized Remediation Plan
1. [Action] - Owner - Due date - Validation method
2. [Action] - Owner - Due date - Validation method

## Appendix
- Tooling and versions:
- Evidence index:
```

## Quality Checks

- Executive content is concise and non-technical.
- Technical findings are reproducible and evidence-backed.
- Remediation steps are specific, testable, and prioritized.
