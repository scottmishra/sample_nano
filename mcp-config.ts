/**
 * NanoClaw MCP Server Configurations
 *
 * Copy the relevant mcpServers entries into your nanoclaw src/index.ts.
 * Pick ONE Azure option (A, B, or C) plus Brave Search.
 */

// =============================================================================
// Brave Search — always include this
// =============================================================================
const braveSearch = {
  "brave-search": {
    command: "npx",
    args: ["-y", "@brave/brave-search-mcp-server", "--transport", "stdio"],
    env: {
      BRAVE_API_KEY: process.env.BRAVE_API_KEY,
    },
  },
};

// =============================================================================
// Option A: Microsoft's official Azure MCP Server (recommended)
//
// Uses existing `az login` credentials automatically.
// Scoped to supported Azure resource management operations.
// =============================================================================
const azureOptionA = {
  "azure-mcp": {
    command: "npx",
    args: ["-y", "@azure/mcp@latest", "server", "start"],
    env: {},
  },
};

// =============================================================================
// Option B: jdubois/azure-cli-mcp (raw az command execution)
//
// Requires Java 17+. More flexible but less guardrails.
// Download: gh release download --repo jdubois/azure-cli-mcp --pattern='azure-cli-mcp.jar'
// =============================================================================
const azureOptionB = {
  "azure-cli": {
    command: "java",
    args: ["-jar", "/path/to/azure-cli-mcp.jar"],
    env: {},
  },
};

// =============================================================================
// Option C: Docker-based (best isolation for SOC 2)
//
// Uses device code flow auth (opens browser).
// Container doesn't have host credentials — better security posture.
// =============================================================================
const azureOptionC = {
  "azure-cli": {
    command: "docker",
    args: [
      "run",
      "-i",
      "--rm",
      "-e",
      "LOG_LEVEL=INFO",
      "ghcr.io/jackinsightsv2/azure-cli-mcp:latest",
    ],
    env: {},
  },
};

// =============================================================================
// Complete config example (Option A + Brave Search)
//
// Paste this into your nanoclaw src/index.ts mcpServers block:
// =============================================================================
export const mcpServers = {
  ...braveSearch,
  ...azureOptionA,
  // Swap azureOptionA for azureOptionB or azureOptionC as needed
};
