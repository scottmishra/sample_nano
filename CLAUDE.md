# NanoClaw — Project Context

## Overview

NanoClaw personal AI assistant with Azure CLI + Brave Search MCP integration.
Accessible via WhatsApp/Telegram. Runs on Claude Agent SDK with Max subscription.

## Available MCP Tools

- **Brave Search** (`brave_web_search`): Web research, news, documentation lookups
- **Azure MCP** (`@azure/mcp`): Azure resource management — VMs, resource groups, Key Vault, Log Analytics, etc.
- **Azure CLI** (if using Option B/C): Raw `az` command execution

## Workflow Patterns

- Use Azure MCP tools for infrastructure management and Azure DevOps operations
- Use Brave Search for researching docs, troubleshooting, finding examples
- Combine both: research a topic via Brave, then apply changes via Azure
- Scheduled tasks: infrastructure checks, cost reports, research briefings

## Azure DevOps Quick Reference

```bash
az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT
az devops project list
az pipelines list
az repos list
az boards work-item list --query "SELECT [System.Id] FROM WorkItems WHERE [System.State] = 'Active'"
```

## Security Notes

- RBAC: Reader on subscription, Contributor only on specific resource groups
- SOC 2: Use Azure MCP Option A or C for audit trail
- Brave API key: rotate regularly, store in Azure Key Vault for production use
- Container isolation: each agent group runs in its own container
