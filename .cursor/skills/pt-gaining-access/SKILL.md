---
name: pt-gaining-access
description: Guides controlled exploitation of validated vulnerabilities to measure real-world impact. Use when the user requests proof-of-concept validation, privilege escalation testing, or attack path confirmation in an authorized environment.
---

# Pen Test Gaining Access

## Authorized Use Only

Only perform controlled exploitation on explicitly approved targets. Avoid destructive actions, production instability, and unnecessary data access. Stop immediately if impact exceeds rules of engagement.

## Objectives

1. Validate whether identified weaknesses are exploitable.
2. Demonstrate business-relevant impact with minimum disruption.
3. Capture reproducible evidence for remediation.

## Workflow

1. Select candidates:
   - Use only prioritized, in-scope findings from scanning
   - Confirm preconditions and rollback/safety plan
2. Define proof-of-concept boundaries:
   - Minimal payloads to prove exploitability
   - No persistence unless separately authorized
3. Execute controlled validation:
   - Record each step, command, and response
   - Confirm exploit chain and resulting access level
4. Assess blast radius:
   - Determine reachable systems/data from obtained access
   - Validate privilege boundaries and segmentation controls
5. Package evidence:
   - Reproduction steps
   - Impact statement in business terms
   - Immediate containment recommendations

## Output Template

```markdown
# Gaining Access Output

## Tested Vulnerability
- Identifier:
- Target:
- Preconditions:

## Validation Result
- Exploitable: Yes/No/Partial
- Access achieved:
- Impact observed:

## Evidence
- Reproduction steps:
- Logs/screenshots/artifacts:

## Risk Statement
- Technical impact:
- Business impact:
- Likelihood:

## Handoff
- Needed remediation owners:
- Retest criteria:
```

## Quality Checks

- PoCs are non-destructive and scoped.
- Evidence is enough for independent reproduction.
- Impact is clearly tied to business risk.
