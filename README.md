# Ethical Hacking AI Agent Skills

This repository contains a collection of AI agent skills. These skills are designed based on the official [Agent Skills specification](https://agentskills.io/specification).

## How to use these skills

1. Clone this repository.
2. Copy one or more skill folders from `skills/` into your agent's skill directory (each skill must remain a directory containing `SKILL.md`).
3. Keep `SKILL.md` frontmatter spec-compliant (`name` must match the folder name; `description` should state what the skill does and when to use it).
4. Optionally validate a skill with `skills-ref validate ./skills/<skill-name>`.

## Included Skills

Portable (agent-agnostic) skill directories:

- `skills/pt-planning-recon/`
- `skills/pt-scanning/`
- `skills/pt-gaining-access/`
- `skills/pt-maintaining-access/`
- `skills/pt-post-exploitation/`
- `skills/pt-analysis-reporting/`
- `skills/pt-report-creation/`
- `skills/pt-fuzzing-web-api/`
- `skills/pt-fuzzing-binary-protocol/`
- `skills/pt-lotl-techniques/`
- `skills/pt-lotl-detection-hardening/`
- `skills/pt-lotl-investigation-reporting/`
- `skills/pt-nuclei-template-creation/`
- `skills/pt-web-application-assessment/`
- `skills/pt-embedded-device-assessment/`

## Notes

- These skills are structured for authorized penetration testing workflows.
- Each skill includes required frontmatter (`name`, `description`) and concise operational guidance.
