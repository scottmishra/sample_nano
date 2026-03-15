#!/usr/bin/env bash
set -euo pipefail

# azure-resources.sh - Common Azure resource management commands
# Run these directly, or use them as prompts in Claude CLI

echo "=== Azure Resource Examples ==="
echo ""

echo "--- Resource Groups ---"
az group list --output table

echo ""
echo "--- Virtual Machines ---"
az vm list --output table

echo ""
echo "--- Storage Accounts ---"
az storage account list --output table

echo ""
echo "--- App Services ---"
az webapp list --output table

# Uncomment to create a test resource group:
# az group create --name nanoclaw-test --location eastus

# Uncomment to list resources in a specific group:
# az resource list --resource-group nanoclaw-test --output table
