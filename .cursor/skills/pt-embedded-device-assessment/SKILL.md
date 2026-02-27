---
name: pt-embedded-device-assessment
description: Performs authorized security assessment of embedded and IoT devices across hardware, firmware, interfaces, and update mechanisms. Use when testing device boot flows, debug interfaces, firmware integrity, and local/network attack surfaces.
---

# Embedded Device Assessment

## Authorized Use Only

Embedded testing can damage hardware or interrupt operations. Confirm explicit authorization, safe handling procedures, and recovery plans before interacting with devices.

## Objectives

1. Evaluate device security from physical access through runtime operation.
2. Identify weaknesses in firmware, interfaces, and update paths.
3. Determine practical exploitability and fleet-level impact.

## Workflow

1. Define test environment:
   - Device models, firmware versions, accessories, and network topology
   - Recovery procedures, spare hardware, and fail-safe boundaries
2. Enumerate interfaces:
   - Physical (UART/JTAG/SWD), wireless, network services, companion apps
   - Boot modes and exposed maintenance/debug channels
3. Assess firmware and boot trust:
   - Firmware extraction and integrity validation where authorized
   - Secure boot, signature checks, rollback protections, key handling
4. Evaluate runtime security:
   - Local and remote service hardening
   - Credential storage, update mechanism security, telemetry exposure
5. Validate impact and remediation:
   - Demonstrate constrained exploitability
   - Recommend secure defaults and manufacturing/update controls

## Output Template

```markdown
# Embedded Assessment Output

## Device Context
- Model/version:
- Firmware build:
- Deployment context:

## Interface Findings
- Interface:
  - Exposure:
  - Weakness:
  - Evidence:
  - Impact:

## Firmware and Boot Findings
- Control tested:
  - Result:
  - Evidence:
  - Risk:

## Remediation Plan
- Immediate mitigations:
- Long-term architecture fixes:
- Validation/retest steps:
```

## Quality Checks

- Safety and recovery constraints are documented and followed.
- Findings distinguish single-device vs fleet-wide risk.
- Recommendations address lifecycle: manufacturing, provisioning, updates, and decommissioning.
