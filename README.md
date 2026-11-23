# Olympus

Home of the gods: a set of lean AI coding skills. Each skill is one folder with a SKILL.md, named for what it does.

Public repo. Never add secrets, client data, keys or private project details here.

## The gods
- TITAN-the-developer (titan-the-developer): senior full stack engineer, any stack. Huge strength.
- ATHENA-the-designer (athena-the-designer): product designer. Users, journeys, UI, and UX friction detection.
- ATLAS-the-planner (atlas-the-planner): turns an idea into a short spec and build order. Carries the whole plan.
- AEGIS-the-auditor (aegis-the-auditor): attacks the system, OWASP, CORS, rate limits, fingerprinting. The shield.
- ARGUS-the-reviewer (argus-the-reviewer): code review and codebase organising. A hundred eyes.
- PROMETHEUS-the-tester (prometheus-the-tester): debugging, tests and QA. Forethought, catch it before users do.
- HEPHAESTUS-the-mobile-builder (hephaestus-the-mobile-builder): Expo and React Native for Android first users. God of the forge.

Coming as they are finished: HERMES-the-deployer, MIDAS-the-dealmaker.

## Install
Needs git. Installs into `~/.claude/skills` (Claude Code, global).

Mac, Linux or Git Bash:
```
curl -fsSL https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.sh | bash
```
Windows PowerShell:
```
iex (irm https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.ps1)
```
Only some skills, or only this project (`.claude/skills` in the current folder):
```
curl -fsSL https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.sh | bash -s -- titan-the-developer atlas-the-planner
curl -fsSL https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.sh | bash -s -- --project
```
```
irm https://raw.githubusercontent.com/Alphred-OB/Olympus/main/install.ps1 -OutFile install.ps1
./install.ps1 -Only titan-the-developer,atlas-the-planner
./install.ps1 -Project
```
Update later by running the same command again. Or use the skills CLI: `npx skills add Alphred-OB/Olympus`.

Check the script before you run it: it only clones this repo and copies the skills folders.

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
- One folder per skill, named god-the-role in lowercase with hyphens (tools need lowercase). Display titles put the god in capitals: TITAN-the-developer. The SKILL.md name must match the folder.
- Keep skills short. No secrets. No client names.
- Change a skill in one place only, then commit with a message that says why.
