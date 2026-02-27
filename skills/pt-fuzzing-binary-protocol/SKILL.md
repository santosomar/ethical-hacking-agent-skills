---
name: pt-fuzzing-binary-protocol
description: Performs authorized fuzz testing of binary formats and network protocols to uncover parser vulnerabilities, memory safety defects, and denial-of-service conditions. Use when assessing protocol handlers, file parsers, and service robustness against malformed inputs.
---

# Binary and Protocol Fuzzing

## Authorized Use Only

Binary/protocol fuzzing can crash services and devices. Use only in approved environments with rollback and recovery plans. Never run uncontrolled campaigns against production systems.

## Objectives

1. Discover crash, hang, and memory-safety conditions.
2. Validate robustness of protocol and file-format parsers.
3. Deliver minimized proof cases and remediation priorities.

## Workflow

1. Prepare target and harness:
   - Define target binary/service and exact version
   - Build repeatable harness with deterministic input path
   - Configure sanitizers/debug symbols where possible
2. Seed and dictionary strategy:
   - Collect representative valid corpus
   - Add protocol/file dictionaries and boundary-value cases
3. Run controlled fuzzing campaign:
   - Configure time budgets, resource limits, and crash retention
   - Monitor for crashes, hangs, OOM, and sanitizer signals
4. Triage and minimize:
   - Deduplicate by stack/signature
   - Reduce to minimal reproducer inputs
   - Confirm exploitability class and likely impact
5. Remediation guidance:
   - Parser hardening and defensive bounds checking
   - Safer decoding patterns and dependency upgrades
   - Regression harness for fixed cases

## Output Template

```markdown
# Binary/Protocol Fuzzing Output

## Campaign Setup
- Target and version:
- Harness:
- Sanitizers/instrumentation:
- Runtime limits:

## Crash and Hang Findings
- Finding ID:
  - Trigger input:
  - Signal/exception:
  - Stack/signature:
  - Reproduction steps:
  - Impact classification:
  - Suggested fix:

## Triage Summary
- Unique findings:
- Duplicates removed:
- Highest-risk classes:

## Regression Plan
- Repro corpus location:
- Required tests after patch:
```

## Quality Checks

- Each finding has a minimized reproducer.
- Crash signatures are deduplicated and prioritized.
- Fix recommendations map to concrete parser hardening actions.
