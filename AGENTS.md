# Agents

This file explains how to use AI agents in this repository. It is short, practical, and safe to follow.

## Scope

- This repo is a World of Warcraft addon.
- The main language is Lua; tools and docs may use Markdown or Python.
- The goal is to keep changes small, readable, and compatible with WoW's UI API.

## Modules

- Modules live in the Modules/ folder and should stay focused on one feature.
- Use LibRu.Module.New to declare modules and keep dependencies explicit.

## File Structure And Section Dividers
- Core.lua bootstraps the addon and wires LibRu.
- Modules/ contains feature modules; Libs/LibRu contains shared framework code.
- Keep module files laid out as: header, dependencies/locals, settings, implementation.
- Use section dividers for major blocks: 
```
--- ======================================================
--- My Major Block
--- ====================================================== 
```

## Common Block Structures

Use these templates to keep files consistent. Prefer existing order if a file already follows a pattern.

### Module File Template

```lua
local addon, ns = ...;

-- =======================================================
-- Module dependency validation + Definition
-- =======================================================

---@class BetterTransmog
local Core = ns.Core;

--- @class BetterTransmog.Modules.Example : LibRu.Module
local Module = Core.Libs.LibRu.Module.New(
	"Example",
	Core,
	{
		Core
	},
	false
)

--- ======================================================
--- locals
--- ======================================================

--- ======================================================
--- Settings
--- ======================================================

--- ======================================================
--- Module Implementation
--- ======================================================

function Module:OnInitialize()
end
```

### Module With Dependencies

```lua
--- ======================================================
--- Dependencies
--- ======================================================
---@type BetterTransmog.Modules.AccountDB
local accountDBModule = Core.Modules.AccountDB;
```


## Guardrails

- Do not change public APIs unless requested.
- Avoid new dependencies unless required.
- Prefer existing helpers in LibRu before adding new ones.
- Keep formatting consistent with surrounding code.
- Avoid non-ASCII characters unless the file already uses them.

## Reference Source

- When looking up Blizzard UI source, use Townlong Yak's live FrameXML: https://www.townlong-yak.com/framexml/live/
- Prefer matching the current build and verify APIs there before proposing changes.

## Commit Guidance

## Contact

- If anything is unclear, ask the repo owner for guidance.
