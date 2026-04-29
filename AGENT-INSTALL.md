# 1c-lean-pipeline — Installation, Update and File Layout

This document describes how an AI agent or the PowerShell fallback installs the
`1c-lean-pipeline` add-on into a project.

Source files live in `content/`, placement rules live in `adapters/*.yaml`, and
the target project receives tool-native files.

## Installation Channels

1. **Agent-driven channel**: preferred when the user asks an AI agent to install
   the add-on. The agent reads this document and `adapters/*.yaml`, then places
   files into the project.
2. **PowerShell fallback**: `install.ps1` implements the same protocol for
   reproducible local or CI runs.

A project installed by one channel can later be updated by the other.

## Agent Protocol

Run the protocol from the target project root.

### Defaults

- **Source**: use the local checkout if the user pointed at one; otherwise clone
  the repository first and use that checkout as the source.
- **Active tools**: detect tools from `adapters/*.yaml`.
- **Confirmation**: ask before overwriting a file that exists and is not owned by
  `.1c-lean-pipeline.json`.
- **Dependency**: this add-on expects the base 1C rules and subagents from
  `https://github.com/comol/ai_rules_1c` to be installed separately.

### Tool Detection

For each adapter, a tool is active when any `detection.exists` path exists in
the target project.

- Exactly one tool detected: install for it.
- More than one tool detected: install for all detected tools unless the user
  explicitly requested a subset.
- No tools detected: ask once which tools to install for:
  `cursor`, `claude-code`, `codex`, `opencode`, `kilocode`.

### Placement

Read only the adapter files and file frontmatter when possible. Do not read every
skill file body before copying; skills are copied verbatim.

For every selected tool:

1. Copy `content/skills/1c-lean-pipeline/` to the adapter's `skills.copyTo`.
2. Copy `content/rules/code-explorer-rules.md` to the adapter's `rules.copyTo`
   target and apply the adapter frontmatter rules.
3. Copy `content/agents/1c-code-explorer.md` to the adapter's `agents.copyTo`
   target and apply frontmatter rules. For Codex, rebuild the agent as TOML
   using `agents.template`.
4. If the adapter has an `entry` block, create the entry file only when it does
   not already exist. Never overwrite a user-authored entry file silently.
5. Write or refresh `.1c-lean-pipeline.json`.
6. If the target project already has `.gitignore`, ensure it contains
   `.1c-lean-pipeline.json`. Do not create `.gitignore` just for this entry.

OpenCode note: use `.opencode/skills/1c-lean-pipeline/` as the native OpenCode
skill path. OpenCode can also read `.claude/skills/`, but this installer keeps
the OpenCode-owned copy under `.opencode/skills/` to avoid hidden coupling.

### Manifest

The manifest `.1c-lean-pipeline.json` is authoritative for files owned by this
add-on. It must contain:

- `protocolVersion`
- `source`
- `installedAt`
- `tools`
- `files[]` with `tool`, `source`, `target`, and `sha256`
- `foreignFiles[]` for existing files that were not overwritten

Do not modify `.ai-rules.json`; it belongs to `comol/ai_rules_1c`.

When `.gitignore` exists, `.1c-lean-pipeline.json` should be listed there
because it is install-state, not project source.

### Update / Add / Remove

- **init**: install selected or detected tools. Existing foreign files are
  preserved unless the user confirms overwrite.
- **update**: refresh files already owned by the manifest and install any newly
  selected tools.
- **add `<tool>`**: install one additional tool and merge it into the manifest.
- **remove `[<tool>]`**: delete managed files for one tool, or all managed files
  when no tool is specified. Do not delete user-owned files.
- **doctor**: read-only diagnostic of source files, adapters, target tools, and
  manifest consistency.
- **eject**: delete only `.1c-lean-pipeline.json`; leave installed files in
  place.

## PowerShell Fallback

Clone the source repository first, then run the script as a file:

```powershell
git clone https://github.com/jsfilatov/1c-lean-pipeline.git $env:TEMP\1c-lean-pipeline
& $env:TEMP\1c-lean-pipeline\install.ps1 init -Source $env:TEMP\1c-lean-pipeline
```

Supported commands:

```powershell
.\install.ps1 init   -Source <path> [-Tools cursor,claude-code] [-NonInteractive] [-AssumeYes]
.\install.ps1 update -Source <path> [-Tools cursor,claude-code] [-NonInteractive] [-AssumeYes]
.\install.ps1 add    -Source <path> -Tool cursor [-NonInteractive] [-AssumeYes]
.\install.ps1 remove [-Tool cursor] [-NonInteractive] [-AssumeYes]
.\install.ps1 doctor [-Source <path>] [-Tools cursor,claude-code]
.\install.ps1 eject  [-NonInteractive] [-AssumeYes]
```

Do not pipe `install.ps1` into `Invoke-Expression`; run it as a script file so
PowerShell can parse its `param(...)` block correctly.
