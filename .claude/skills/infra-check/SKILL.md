# Infrastructure Check

When the user asks to check infrastructure status:

1. Use azure-mcp to list VMs and their power states
2. Use azure-mcp to check Key Vault health and expiring secrets/certificates
3. Use azure-mcp to query Log Analytics for recent errors or anomalies
4. Use brave-search to check for any active Azure service incidents or outages
5. Use azure-mcp to pull current cost analysis vs. budget
6. Summarize findings with:
   - Current resource status (healthy / degraded / down)
   - Any expiring secrets or certificates in the next 30 days
   - Azure incident impacts (if any)
   - Cost anomalies vs. prior week
   - Action items requiring attention
