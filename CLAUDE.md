# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A collection of portable AI agent skills for authorized penetration testing workflows, written against the [Agent Skills specification](https://agentskills.io/specification). There is no application code, build system, or test suite — the repo is entirely markdown content under `skills/`.

## Commands

Validate a skill against the spec:

```bash
skills-ref validate ./skills/<skill-name>
```

## Skill file format

Every skill is a directory `skills/<skill-name>/` containing exactly one `SKILL.md`. The file must open with YAML frontmatter:

```yaml
---
name: <skill-name>        # MUST match the directory name exactly
description: <...>        # What it does + when the agent should invoke it
---
```

The `description` is what the agent reads to decide when to trigger the skill, so it must state both the capability and the trigger conditions (see any existing skill for phrasing: "Use when...").

## Skill body structure

All skills in this repo follow the same section order. Match it when adding or editing skills:

1. `## Authorized Use Only` — omitted only for pure-reporting skills (`pt-report-creation`, `pt-analysis-reporting`) that don't touch targets
2. `## Objectives` — numbered list, 3–4 items
3. `## Workflow` — numbered top-level steps with indented bullet sub-steps
4. `## Output Template` — a fenced ```` ```markdown ```` block the agent fills in
5. `## Quality Checks` — bullet list of acceptance criteria

Skills may add extra sections between Workflow and Output Template when warranted (e.g. `pt-lotl-techniques` has platform-specific `## Windows Techniques` / `## Unix Techniques`).

## Handoff chain

The skills model a pentest engagement as a pipeline. Each phase's Output Template ends with a `## Handoff to <next-phase>` section that becomes the input for the next skill:

```
pt-planning-recon → pt-scanning → pt-gaining-access → pt-maintaining-access / pt-post-exploitation → pt-analysis-reporting / pt-report-creation
```

Specialized skills (`pt-fuzzing-*`, `pt-lotl-techniques`, `pt-web-application-assessment`, `pt-embedded-device-assessment`) feed into the reporting phase rather than chaining linearly. When editing an Output Template, keep the handoff section aligned with what the downstream skill expects to consume.

## README drift

README.md lists `.cursor/skills/` mirror copies that do not currently exist in the working tree. If adding a skill, update README's `Included Skills` list; do not assume the `.cursor/` mirror is maintained.
