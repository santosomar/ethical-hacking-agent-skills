---
name: pt-maintaining-access
description: Evaluates whether an attacker could retain foothold and move laterally after initial compromise, within strict authorization limits. Use when testing persistence, session resilience, and detection/response effectiveness during a pen test.
---

# Pen Test Maintaining Access

## Authorized Use Only

Persistence simulation requires explicit approval. Prefer temporary, reversible techniques and remove all artifacts during cleanup. Never leave backdoors, accounts, or scheduled tasks in place after testing.

## Objectives

1. Determine whether access can survive control changes and reboots.
2. Assess lateral movement opportunities from compromised context.
3. Measure detection and response effectiveness.

## Workflow

1. Confirm persistence permissions:
   - Allowed mechanisms
   - Maximum dwell time
   - Mandatory cleanup expectations
2. Simulate persistence safely:
   - Use low-risk, reversible methods appropriate to target class
   - Validate whether persistence survives expected environmental changes
3. Evaluate lateral movement opportunities:
   - Trust relationships, token reuse, shared credentials, weak segmentation
   - Keep movement minimal and auditable
4. Test detection/response:
   - Document whether controls trigger and how quickly teams react
   - Capture gaps in telemetry and containment
5. Cleanup and verify:
   - Remove all test artifacts
   - Recheck system state to confirm rollback

## Output Template

```markdown
# Maintaining Access Output

## Persistence Simulation
- Technique class:
- Target:
- Result:
- Reversibility check:

## Lateral Movement Assessment
- Starting context:
- Reachable systems:
- Constraints encountered:

## Detection and Response
- Alerts triggered:
- Time to detect:
- Time to contain:
- Gaps observed:

## Cleanup Verification
- Artifacts removed:
- Validation method:
```

## Quality Checks

- All persistence actions were pre-approved and reversible.
- Evidence includes timeline from initial foothold to cleanup.
- Detection gaps are mapped to concrete control improvements.
