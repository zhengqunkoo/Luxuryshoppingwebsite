---

# Trigger - run before deploy-to-azure workflow
on:
  workflow_run:
    workflows: ["Build and Deploy to Azure"]
    types:
      - requested
      - completed

# Permissions - what can this workflow access?
permissions:
  contents: read
  issues: write
  pull-requests: write

# Outputs - what APIs and tools can the AI use?
safe-outputs:
  create-issue:          # Creates issues (default max: 1)
    max: 5               # Optional: specify maximum number
  # create-agent-session:   # Creates GitHub Copilot agent sessions (max: 1)
  # create-pull-request: # Creates exactly one pull request
  # add-comment:   # Adds comments (default max: 1)
  #   max: 2             # Optional: specify maximum number
  # add-labels:

---

# Azure Resource Pre-Check Skill for GitHub Actions

## Skill: azure-resource-precheck

This skill verifies that all required Azure resources and subnets exist in the specified resource group and virtual network before proceeding with deployment. It uses the Azure CLI and fuzzy/AI logic to match expected resources.

---

## Pre-Check Steps

### 1. List All Top-Level Resources in Resource Group

```sh
az resource list --resource-group rg-oslp-prod-003 --output table
```

**Expected (fuzzy match):**
- asp-oslp-prod (Microsoft.Web/serverFarms)
- vnet-oslp-prod-003 (Microsoft.Network/virtualNetworks)
- sql-oslp-prod-003 (Microsoft.Sql/servers)
- kv-oslp-prod-003 (Microsoft.KeyVault/vaults)
- aks-oslp-prod-003 (Microsoft.ContainerService/managedClusters)
- acroslpprod003 (Microsoft.ContainerRegistry/registries)
- app-oslp-prod-003 (Microsoft.Web/sites)
- sql-oslp-prod-003/master (Microsoft.Sql/servers/databases)
- sql-oslp-prod-003/sqldb-oslp-prod (Microsoft.Sql/servers/databases)

### 2. List All Subnets in the VNet

```sh
az network vnet subnet list --resource-group rg-oslp-prod-003 --vnet-name vnet-oslp-prod-003 --output table
```

**Expected (fuzzy match):**
- snet-compute (10.0.2.0/24)
- snet-ingress (10.0.1.0/24)
- snet-paas (10.0.3.0/24)

---

## AI/Fuzzy Logic
- Use string similarity or AI-based matching to allow for minor naming or status differences.
- If any required resource or subnet is missing, fail the pre-check and provide a clear error message.
- If all are present, proceed with the workflow.

---

## Usage
- Add this skill as a pre-check step in your GitHub Actions workflow before running Terraform or deployment steps.
- The skill should output a summary of missing or mismatched resources if the check fails.

---

## Example Output

**Success:**
```
All required Azure resources and subnets are present in rg-oslp-prod-003.
```

**Failure:**
```
Missing resources: app-oslp-prod-003 (Microsoft.Web/sites), snet-paas (subnet)
```

---

## Integration
- This skill can be invoked as a GitHub Actions step or as a reusable workflow.
- It is designed to be used in CI/CD pipelines for Azure infrastructure validation.

---

## Instructions

1. Run the two Azure CLI commands above.
2. Use fuzzy/AI logic to match the output against the expected resources and subnets.
3. If any are missing, fail the pre-check and output a clear error message.
4. If all are present, output a success message and proceed.

---

## Notes

- Run `gh aw compile` to generate the GitHub Actions workflow
- See https://github.github.com/gh-aw/ for complete configuration options and tools documentation
