# nanoclaw Quickstart Guide

A minimal setup to run Azure CLI and Azure DevOps workloads through Claude CLI, with Brave Search for research — powered by your Claude Max subscription.

## What you get

- **Claude CLI** as your AI-powered command interface
- **Azure CLI** (`az`) for managing Azure resources and Azure DevOps
- **Brave Search MCP** for web research directly from Claude

## Prerequisites

| Tool | Install |
|------|---------|
| Claude CLI | `npm install -g @anthropic-ai/claude-code` |
| Azure CLI | [Install guide](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) |
| Node.js 18+ | [nodejs.org](https://nodejs.org) |
| Brave Search API key | [brave.com/search/api](https://brave.com/search/api/) (free tier available) |
| Claude Max subscription | Already active on your account |

## Quick start

```bash
# 1. Clone this repo
git clone <this-repo-url> && cd sample_nano

# 2. Log in to Azure (if not already)
az login

# 3. Set your Brave Search key
export BRAVE_API_KEY=your-key-here

# 4. Run the start script
./nanoclaw-start.sh
```

The script checks prerequisites, writes the MCP config, and drops you into Claude CLI.

## Example prompts

Once Claude CLI is running, try:

### Azure resources
```
List all my resource groups and their locations
```
```
Show me VMs that are currently running
```
```
Create a new resource group called "nanoclaw-test" in eastus
```

### Azure DevOps
```
List my Azure DevOps projects
```
```
Show recent pipeline runs for my project
```
```
List open work items assigned to me
```

### Research with Brave Search
```
Search for Azure Functions best practices 2026
```
```
Research how to set up Azure DevOps service connections
```

### Combined workflows
```
Research the latest Azure Kubernetes Service pricing, then list my current AKS clusters
```

## Project structure

```
sample_nano/
├── nanoclaw-start.sh        # Startup script — run this
├── CLAUDE.md                # Project context for Claude CLI
├── README.md                # This file
└── examples/
    ├── azure-resources.sh   # Example: manage Azure resources
    └── azure-devops.sh      # Example: Azure DevOps operations
```

## Configuration

### Azure DevOps defaults

Set your org and project once so you don't repeat them:

```bash
az devops configure --defaults \
  organization=https://dev.azure.com/YOUR_ORG \
  project=YOUR_PROJECT
```

### Brave Search API

The free tier gives 2,000 queries/month — plenty for research workflows.
Get your key at [brave.com/search/api](https://brave.com/search/api/).

## How it works

1. `nanoclaw-start.sh` verifies your tools are installed and you're logged in
2. It writes `.claude/mcp.json` to register the Brave Search MCP server
3. It creates `CLAUDE.md` with project context so Claude knows what tools are available
4. It launches `claude` CLI — your Max subscription is used automatically
5. Claude can run `az` commands directly and search the web via Brave
