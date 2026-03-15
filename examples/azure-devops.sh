#!/usr/bin/env bash
set -euo pipefail

# azure-devops.sh - Common Azure DevOps commands
# Run these directly, or use them as prompts in Claude CLI
#
# First, set your defaults:
#   az devops configure --defaults organization=https://dev.azure.com/YOUR_ORG project=YOUR_PROJECT

echo "=== Azure DevOps Examples ==="
echo ""

echo "--- Projects ---"
az devops project list --output table

echo ""
echo "--- Repositories ---"
az repos list --output table

echo ""
echo "--- Pipelines ---"
az pipelines list --output table

echo ""
echo "--- Recent Pipeline Runs ---"
az pipelines runs list --top 5 --output table

# Uncomment for work items:
# echo ""
# echo "--- Active Work Items ---"
# az boards work-item list --query "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.State] = 'Active'" --output table
