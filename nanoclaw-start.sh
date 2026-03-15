#!/usr/bin/env bash
set -euo pipefail

# nanoclaw-start.sh - Quick start script for nanoclaw workloads
# Uses your existing Claude Max subscription via Claude CLI
# Configures MCP servers for Azure CLI and Brave Search

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/.claude"
MCP_CONFIG="${CONFIG_DIR}/mcp.json"

echo "=== nanoclaw quickstart ==="
echo ""

# --- Pre-flight checks ---
check_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: '$1' is not installed or not in PATH."
    echo "  Install: $2"
    return 1
  fi
  echo "  [ok] $1"
}

echo "Checking prerequisites..."
MISSING=0
check_tool "claude"  "npm install -g @anthropic-ai/claude-code"  || MISSING=1
check_tool "az"      "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli" || MISSING=1
check_tool "npx"     "Install Node.js >= 18 from https://nodejs.org" || MISSING=1

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "Install the missing tools above, then re-run this script."
  exit 1
fi

# --- Check Azure login ---
echo ""
echo "Checking Azure CLI login..."
if ! az account show &>/dev/null; then
  echo "  You are not logged in to Azure. Launching login..."
  az login
fi
AZ_ACCOUNT=$(az account show --query name -o tsv 2>/dev/null || echo "unknown")
echo "  [ok] Logged in to Azure subscription: ${AZ_ACCOUNT}"

# --- Check Brave Search API key ---
echo ""
if [ -z "${BRAVE_API_KEY:-}" ]; then
  echo "BRAVE_API_KEY is not set."
  echo "  Get a free key at: https://brave.com/search/api/"
  echo "  Then export it:    export BRAVE_API_KEY=your-key-here"
  echo ""
  read -rp "Enter your Brave Search API key (or press Enter to skip): " BRAVE_KEY_INPUT
  if [ -n "$BRAVE_KEY_INPUT" ]; then
    export BRAVE_API_KEY="$BRAVE_KEY_INPUT"
    echo "  [ok] BRAVE_API_KEY set for this session"
  else
    echo "  [skip] Brave Search will not be available"
  fi
else
  echo "  [ok] BRAVE_API_KEY is set"
fi

# --- Write MCP config ---
echo ""
echo "Writing MCP config to ${MCP_CONFIG}..."
mkdir -p "$CONFIG_DIR"

# Build the MCP servers JSON
MCP_SERVERS='{
  "azure-cli": {
    "type": "command",
    "command": "az",
    "description": "Azure CLI - manage Azure resources and Azure DevOps"
  }'

if [ -n "${BRAVE_API_KEY:-}" ]; then
  MCP_SERVERS="${MCP_SERVERS}"',
  "brave-search": {
    "type": "command",
    "command": "npx",
    "args": ["-y", "@anthropic-ai/brave-search-mcp"],
    "env": {
      "BRAVE_API_KEY": "'"${BRAVE_API_KEY}"'"
    },
    "description": "Brave Search API for web research"
  }'
fi

cat > "$MCP_CONFIG" << MCPEOF
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY:-}"
      }
    }
  }
}
MCPEOF

echo "  [ok] MCP config written"

# --- Write CLAUDE.md project context ---
CLAUDE_MD="${SCRIPT_DIR}/CLAUDE.md"
if [ ! -f "$CLAUDE_MD" ]; then
  cat > "$CLAUDE_MD" << 'CLAUDEEOF'
# nanoclaw project context

## Available tools

- **Azure CLI (`az`)**: Manage Azure resources and Azure DevOps.
  Common commands: `az group list`, `az devops project list`, `az vm list`
- **Brave Search**: Web research via MCP server (when BRAVE_API_KEY is set).

## Workflow patterns

- Use `az` commands for Azure resource management and Azure DevOps operations
- Use Brave Search for researching docs, troubleshooting, or finding examples
- Combine both: research a topic, then apply changes via Azure CLI

## Azure DevOps quick reference

- `az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT`
- `az devops project list`
- `az pipelines list`
- `az repos list`
- `az boards work-item list --query "SELECT [System.Id] FROM WorkItems WHERE [System.State] = 'Active'"`
CLAUDEEOF
  echo "  [ok] CLAUDE.md created"
fi

# --- Launch Claude CLI ---
echo ""
echo "=== Ready! ==="
echo ""
echo "Launching Claude CLI in this project directory..."
echo "Your Claude Max subscription will be used automatically."
echo ""
echo "Try these example prompts:"
echo '  "List all my Azure resource groups"'
echo '  "Show me my Azure DevOps projects"'
echo '  "Research best practices for Azure Functions and summarize"'
echo ""

cd "$SCRIPT_DIR"
exec claude
