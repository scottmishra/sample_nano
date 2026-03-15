#!/usr/bin/env bash
set -euo pipefail

# setup.sh — NanoClaw bootstrap script
# Forks nanoclaw, installs deps, copies configs, and launches Claude Code /setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== NanoClaw Quickstart Bootstrap ==="
echo ""

# ---- Pre-flight checks ----
check_tool() {
  if ! command -v "$1" &>/dev/null; then
    echo "  [MISSING] $1 — $2"
    return 1
  fi
  echo "  [ok] $1"
}

echo "Checking prerequisites..."
MISSING=0
check_tool "claude" "npm install -g @anthropic-ai/claude-code"                              || MISSING=1
check_tool "az"     "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli"         || MISSING=1
check_tool "node"   "https://nodejs.org (v20+ required)"                                     || MISSING=1
check_tool "npx"    "Comes with Node.js"                                                     || MISSING=1
check_tool "gh"     "https://cli.github.com"                                                 || MISSING=1
check_tool "docker" "https://docs.docker.com/get-docker/ (or Apple Containers on macOS)"     || MISSING=1

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "Install the missing tools above, then re-run this script."
  exit 1
fi

# Check Node version
NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "  [ERROR] Node.js 20+ required, found $(node -v)"
  exit 1
fi
echo "  [ok] Node.js $(node -v)"

# ---- Azure login check ----
echo ""
echo "Checking Azure CLI login..."
if ! az account show &>/dev/null; then
  echo "  Not logged in — launching az login..."
  az login
fi
AZ_ACCOUNT=$(az account show --query name -o tsv 2>/dev/null || echo "unknown")
echo "  [ok] Azure subscription: ${AZ_ACCOUNT}"

# ---- Brave API key ----
echo ""
if [ -z "${BRAVE_API_KEY:-}" ]; then
  if [ -f "${SCRIPT_DIR}/.env" ]; then
    # Try loading from .env
    BRAVE_API_KEY=$(grep -E '^BRAVE_API_KEY=' "${SCRIPT_DIR}/.env" | cut -d= -f2- || true)
  fi
fi

if [ -z "${BRAVE_API_KEY:-}" ]; then
  echo "BRAVE_API_KEY not set."
  echo "  Get a free key at: https://search.brave.com/api"
  echo ""
  read -rp "Enter your Brave Search API key (or Enter to skip): " BRAVE_KEY_INPUT
  if [ -n "$BRAVE_KEY_INPUT" ]; then
    export BRAVE_API_KEY="$BRAVE_KEY_INPUT"
    echo "  [ok] BRAVE_API_KEY set for this session"
  else
    echo "  [skip] Brave Search will not be available"
  fi
else
  echo "  [ok] BRAVE_API_KEY is set"
fi

# ---- Fork and clone NanoClaw ----
echo ""
NANOCLAW_DIR="${SCRIPT_DIR}/nanoclaw"

if [ -d "$NANOCLAW_DIR" ]; then
  echo "nanoclaw/ directory already exists — skipping fork/clone."
else
  echo "Forking and cloning qwibitai/nanoclaw..."
  gh repo fork qwibitai/nanoclaw --clone --fork-name nanoclaw
  # gh clones into ./nanoclaw by default
fi

# ---- Copy config templates into the fork ----
echo ""
echo "Copying config templates into nanoclaw/..."

# MCP config reference
cp "${SCRIPT_DIR}/mcp-config.ts" "${NANOCLAW_DIR}/mcp-config.ts"

# Claude Code skills
if [ -d "${SCRIPT_DIR}/.claude/skills" ]; then
  mkdir -p "${NANOCLAW_DIR}/.claude/skills"
  cp -r "${SCRIPT_DIR}/.claude/skills/"* "${NANOCLAW_DIR}/.claude/skills/"
fi

# CLAUDE.md project context
cp "${SCRIPT_DIR}/CLAUDE.md" "${NANOCLAW_DIR}/CLAUDE.md"

# .env if it exists
if [ -f "${SCRIPT_DIR}/.env" ]; then
  cp "${SCRIPT_DIR}/.env" "${NANOCLAW_DIR}/.env"
elif [ -n "${BRAVE_API_KEY:-}" ]; then
  echo "BRAVE_API_KEY=${BRAVE_API_KEY}" > "${NANOCLAW_DIR}/.env"
fi

echo "  [ok] Templates copied"

# ---- Install dependencies ----
echo ""
echo "Installing NanoClaw dependencies..."
cd "$NANOCLAW_DIR"
npm install

# ---- Azure DevOps defaults (optional) ----
echo ""
if [ -n "${AZDO_ORG:-}" ] && [ -n "${AZDO_PROJECT:-}" ]; then
  echo "Configuring Azure DevOps defaults..."
  az devops configure --defaults organization="$AZDO_ORG" project="$AZDO_PROJECT"
  echo "  [ok] Azure DevOps defaults set"
else
  echo "  [skip] Set AZDO_ORG and AZDO_PROJECT in .env for Azure DevOps defaults"
fi

# ---- Launch Claude Code /setup ----
echo ""
echo "=== Bootstrap complete ==="
echo ""
echo "Next steps:"
echo "  1. cd nanoclaw"
echo "  2. Run: claude"
echo "  3. Inside Claude Code, run: /setup"
echo "     This will walk you through WhatsApp QR auth, SQLite DB, and container runtime."
echo ""
echo "  4. Copy the MCP server config from mcp-config.ts into src/index.ts"
echo "     Or use: /customize → 'Add Brave Search and Azure MCP servers'"
echo ""
echo "  5. Test with a message: @Andy search for latest supply chain AI developments"
echo ""

read -rp "Launch Claude Code now? (Y/n) " LAUNCH
if [ "${LAUNCH:-Y}" != "n" ] && [ "${LAUNCH:-Y}" != "N" ]; then
  cd "$NANOCLAW_DIR"
  exec claude
fi
