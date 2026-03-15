# NanoClaw Quickstart Guide

**Az CLI + Brave Search MCP + Claude Code**

Wire up [NanoClaw](https://github.com/qwibitai/nanoclaw) as a personal AI assistant that manages Azure infrastructure, searches the web via Brave, and leverages Claude Code — accessible from WhatsApp or other messaging channels.

Author: Scott (Sensium AI) | March 2026

---

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                    NanoClaw Host                      │
│  (macOS / Linux — your machine or a dedicated box)   │
│                                                      │
│  ┌─────────────┐                                     │
│  │  index.ts    │  ← Host orchestrator (~700 LOC)    │
│  │  (WhatsApp,  │    SQLite, container lifecycle      │
│  │   Telegram)  │                                     │
│  └──────┬───────┘                                     │
│         │ spawns per-group                            │
│  ┌──────▼────────────────────────────────────────┐   │
│  │         Agent Container (isolated)             │   │
│  │                                                │   │
│  │  Claude Agent SDK                              │   │
│  │    ├── MCP: Azure CLI  (az commands)           │   │
│  │    ├── MCP: Brave Search (web + local search)  │   │
│  │    └── MCP: Azure MCP Server (resource mgmt)   │   │
│  │                                                │   │
│  │  Mounted: group CLAUDE.md, filesystem slice    │   │
│  └────────────────────────────────────────────────┘   │
│                                                      │
│  Claude Code CLI (setup, /customize, /add-*)         │
└──────────────────────────────────────────────────────┘
```

## Prerequisites

| Item | Details |
|------|---------|
| **Claude Code CLI** | `npm install -g @anthropic-ai/claude-code` — authenticated with Max subscription |
| **Azure CLI** | `az login` completed, Entra ID SSH configured |
| **Brave Search API key** | Free tier at [search.brave.com/api](https://search.brave.com/api) — or paid "Data for AI" plan |
| **Node.js 20+** | Required by NanoClaw and MCP servers |
| **Docker** | For container isolation (or Apple Containers on macOS) |
| **Java 17+** | Only if using `jdubois/azure-cli-mcp` (Option B) |

## Quick Start

```bash
# 1. Run the bootstrap script
./setup.sh

# 2. Follow the prompts — it forks NanoClaw, installs deps,
#    configures MCP servers, and runs /setup via Claude Code
```

Or step by step:

```bash
# Fork and clone NanoClaw
gh repo fork qwibitai/nanoclaw --clone
cd nanoclaw

# Copy config templates into the fork
cp ../sample_nano/mcp-config.ts .
cp -r ../sample_nano/.claude/ .claude/
cp ../sample_nano/.env.example .env

# Fill in your .env
vi .env

# Run Claude Code setup
claude
# Inside Claude Code: /setup
```

## Phases

### Phase 1: Fork & Bootstrap (Day 1)

The `setup.sh` script handles this automatically:
1. Forks `qwibitai/nanoclaw`
2. Installs dependencies
3. Runs Claude Code `/setup` for WhatsApp QR auth, SQLite DB, container runtime
4. Verifies baseline — send a test message to confirm the agent responds

### Phase 2: Brave Search MCP (Day 1–2)

Add to `src/index.ts` `mcpServers` config (see `mcp-config.ts` for the snippet):

```typescript
"brave-search": {
  command: "npx",
  args: ["-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
  env: {
    BRAVE_API_KEY: process.env.BRAVE_API_KEY
  }
}
```

Or use Claude Code:
```
/customize
# → "Add Brave Search as an MCP tool so the agent can search the web"
```

**Test:** `@Andy search for latest supply chain AI developments this week`

### Phase 3: Azure CLI MCP (Day 2–3)

Three options — pick based on your risk tolerance:

| Option | Method | Pros | Cons |
|--------|--------|------|------|
| **A (recommended)** | `@azure/mcp` official server | MS-maintained, uses existing `az login` | Scoped to supported operations |
| **B** | `jdubois/azure-cli-mcp` JAR | Raw `az` command execution, most flexible | Needs Java 17+, less guardrails |
| **C (best for SOC 2)** | Docker-based MCP | Full container isolation, device code auth | Slightly more setup |

See `mcp-config.ts` for all three configurations.

**RBAC guidance:**
- **Sensium dev:** Reader on subscription, Contributor on specific resource groups
- **SOC 2 audit queries:** Log Analytics Reader on your workspace
- **Avoid:** Owner or unrestricted Contributor at subscription level

**Test:**
```
@Andy list all VMs in the sensium-dev resource group
@Andy show SOC 2 compliance policy assignments on our subscription
@Andy what's the status of the key vault in our dev environment
```

### Phase 4: Custom Skills (Day 3)

Skills live in `.claude/skills/` — see the included templates:

- **`infra-check`** — Azure infrastructure status + incident check via Brave
- **`research`** — Web research with cross-referencing (e.g., Univar, supply chain)

Scheduled tasks via NanoClaw:
```
@Andy every weekday at 8am, check our Azure infrastructure status and message me a summary
@Andy every Monday at 9am, search for AI developments in supply chain and compile a briefing
@Andy every Friday at 5pm, check Azure cost analysis for the week and flag anomalies
```

### Phase 5: Security & SOC 2 (Ongoing)

| Component | Auth Method | Credential Storage |
|-----------|------------|-------------------|
| Claude Agent SDK | Max OAuth (personal use) | Session-based |
| Azure MCP | `az login` / Entra ID | Host credential cache |
| Brave Search | API key | Environment variable |

**SOC 2 recommendations:**
- Run on a dedicated machine (Mac Mini or small VM), not your daily driver
- Rotate Brave API key regularly; store in Azure Key Vault and pull at startup
- Retain NanoClaw SQLite logs per SOC 2 evidence collection requirements
- Use Option A or C for Azure — better audit trail than raw CLI execution
- Switch to Anthropic API key auth if NanoClaw goes beyond personal use

## Project Structure

```
sample_nano/
├── setup.sh                          # Bootstrap script
├── mcp-config.ts                     # MCP server configs (all 3 Azure options)
├── .env.example                      # Environment variable template
├── CLAUDE.md                         # Project context for Claude Code
├── .claude/
│   └── skills/
│       ├── infra-check/
│       │   └── SKILL.md              # Infrastructure check skill
│       └── research/
│           └── SKILL.md              # Web research skill
└── README.md                         # This file
```

## Checklist

- [ ] Fork nanoclaw repo
- [ ] Get Brave Search API key
- [ ] Decide Azure MCP option (A/B/C) based on risk tolerance
- [ ] Set up on dedicated machine or Docker sandbox
- [ ] Build custom skills for Sensium workflows
- [ ] Add Telegram or Slack channel if WhatsApp isn't preferred
