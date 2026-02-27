---
name: pt-lotl-techniques
description: Demonstrates Living-off-the-Land (LotL) techniques using native OS tools to simulate realistic threat actor behavior during authorized penetration tests. Use when proving attack feasibility without custom malware, testing detection coverage, and validating what a real adversary could achieve with only built-in system capabilities.
---

# Living-off-the-Land (LotL) Techniques

## Authorized Use Only

Execute LotL techniques only within explicitly approved scope, target systems, and test windows. Document every action with timestamps. Stop immediately if impact exceeds rules of engagement.

## Objectives

1. Simulate realistic threat actor behavior using only native OS tools.
2. Demonstrate attack paths without introducing custom malware.
3. Validate detection gaps and measure real-world exploitability.
4. Produce reproducible evidence for reporting.

## Approach

LotL abuses tools that already exist on the target — scripting engines, admin utilities, and built-in OS features — to blend in with legitimate activity.

**Decide platform first, then select techniques:**

- **Windows target** → see Windows Techniques below
- **Linux/macOS target** → see Unix Techniques below
- **Mixed environment** → run applicable sections for each platform

## Windows Techniques

Technique families to demonstrate in approved scope:

- **Execution**: PowerShell, cmd, WScript, CScript, mshta, rundll32, regsvr32
- **Discovery**: net, nltest, ipconfig, whoami, tasklist, reg query, wmic
- **Credential access**: accessing memory-resident material via built-in utilities
- **Lateral movement**: PsExec-style invocation, WMI remote execution, WinRM
- **Persistence**: scheduled tasks (schtasks), registry run keys, service creation (sc)
- **Exfil/staging**: certutil (encode/decode), bitsadmin, curl (built-in), Invoke-WebRequest

For each technique:
1. Confirm it is in scope and the target is approved.
2. Use the minimal invocation needed to prove feasibility.
3. Record full command line, output, and timestamp.
4. Note whether any EDR/SIEM alert fired.

## Unix Techniques

Technique families to demonstrate in approved scope:

- **Execution**: bash, sh, python3, perl, ruby, awk — whichever is present
- **Discovery**: id, uname, hostname, ss/netstat, ps, find, env
- **Credential access**: reading credential files, checking config files for embedded secrets
- **Lateral movement**: SSH key reuse, sudo abuse, cron-assisted pivoting
- **Persistence**: crontab, rc.local/systemd unit, bashrc/profile additions, SSH authorized_keys
- **Exfil/staging**: curl, wget, nc, python http.server, scp

For each technique:
1. Confirm it is in scope and the target is approved.
2. Use minimal, reversible commands that demonstrate the path.
3. Record full command, output, and timestamp.
4. Note whether any monitoring or alerting responded.

## Execution Workflow

1. Review scope and approved target list.
2. Select relevant technique families based on target platform and test goals.
3. Execute techniques one at a time, logging each step.
4. For each successful technique, assess realistic downstream impact.
5. Capture alert/detection response (or absence of it).
6. Clean up any created artefacts (files, tasks, keys, registry keys).
7. Package evidence for reporting.

## Output Template

```markdown
# LotL Techniques Output

## Engagement Context
- Targets:
- Platforms:
- Approved technique families:
- Test window:

## Demonstrated Techniques
### [Technique Name]
- Platform:
- Tool/binary used:
- Command executed:
- Output observed:
- Impact demonstrated:
- Detection triggered: Yes / No / Unknown
- Artefacts created and cleaned up:

## Detection Visibility Summary
- Techniques that triggered alerts:
- Techniques with no detection:
- Overall detection gap assessment:

## Handoff to Reporting
- High-impact paths to highlight:
- Recommended defensive improvements:
```

## Quality Checks

- Every technique execution is timestamped and reproducible.
- All created artefacts are removed during cleanup.
- Detection response (or absence) is documented for every technique.
- Impact is framed in realistic threat-actor terms for the report.
