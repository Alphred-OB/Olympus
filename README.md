# Olympus

Home of the gods: a set of lean AI coding skills. Each skill is one folder with a SKILL.md, named for what it does.

Public repo. Never add secrets, client data, keys or private project details here.

## The gods
- Titan the Developer (titan-the-developer): senior full stack engineer, any stack. Huge strength.
- Atlas the Planner (atlas-the-planner): turns an idea into a short spec and build order. Carries the whole plan.
- Aegis the Auditor (aegis-the-auditor): attacks the system, OWASP, CORS, rate limits, fingerprinting. The shield.
- Hephaestus the Mobile Builder (hephaestus-the-mobile-builder): Expo and React Native for Android first users. God of the forge.

Coming as they are finished: Athena the Designer, Argus the Reviewer, Hermes the Deployer, Midas the Dealmaker, Prometheus the Tester.

## Use in another project
Option 1, copy: copy the folders you need from skills/ into the project at `.claude/skills/` (Claude Code) or any folder your AI tool reads skills from.

Option 2, submodule (stays updatable):
```
git submodule add https://github.com/Alphred-OB/Olympus .Olympus
```
Then copy or link the skill folders from `.Olympus/skills/`. Update with `git submodule update --remote`.

Option 3, single file: use the raw link of a SKILL.md, for example
`https://raw.githubusercontent.com/Alphred-OB/Olympus/main/skills/titan-the-developer/SKILL.md`

## Rules for this repo
- One folder per skill, named god-the-role in lowercase with hyphens (tools need lowercase). Titles inside use capitals: Titan the Developer. The SKILL.md name must match the folder.
- Keep skills short. No secrets. No client names.
- Change a skill in one place only, then commit with a message that says why.
