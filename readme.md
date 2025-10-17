# Active Directory Lab Deployment on Azure with Terraform &amp; Ansible
## Overview
This project provisions a multi-VM Active Directory lab environment in Microsoft Azure using Terraform for infrastructure as code (IaC) and Ansible for post-deployment configuration. The lab simulates a real-world enterprise AD setup with multiple domain controllers, member servers, and clients, enabling scenarios such as domain joins, DNS configuration, and optional trusts between forests.

## What We Have Done
### 1. Infrastructure Provisioning with Terraform

Azure Subscription: Configured under subscription ID b0a3fc70-2e57-4cdb-8d94-6b3e721f6c43.
Resource Group: adlab-rg.
Region: Changed from westeurope to polandcentral to avoid VM SKU capacity issues.
Provider Management:

Resolved provider schema mismatch by pinning azurerm provider to v4 (~&gt; 4.49.0).
Updated lock file and re-initialized with terraform init -upgrade.


Terraform Fixes:

Corrected invalid single-line variable block syntax.
Ensured proper variable definitions for location, admin_password, and dsrm_password.


Networking:

Created Virtual Network (adlab-vnet) and subnets, including AzureBastionSubnet.
Configured NSG (adlab-lab-nsg) with corrected rules:

Removed invalid AzureBastion prefix.
Used AzureCloud or Bastion subnet CIDR for RDP access.




Compute:

Deployed multiple Windows VMs:

Domain Controllers: ContosoDC1, ContosoDC2, ChildDC1, ChildDC2, ChildDC3, FabrikamDC1.
Clients: Client1, Client2.
Member Server: Server1.


Created NICs, Availability Set, and associated resources.


Bastion Host:

Configured Azure Bastion for secure RDP access without exposing public RDP ports.


State Management:

Imported all pre-existing resources into Terraform state to ensure full lifecycle management.
Verified clean terraform plan with no drift.




### 2. Secrets Handling

Avoided hardcoding sensitive values.
Recommended approaches:

Environment variables (TF_VAR_admin_password, TF_VAR_dsrm_password).
.auto.tfvars files (excluded from version control).
Azure Key Vault integration (optional).






          
            
          
        
  
        
    

3. Current Infrastructure State

All core Azure resources (RG, VNet, Subnets, NSG, Bastion, NICs, VMs) are deployed and managed by Terraform.
Terraform state is consistent and up-to-date.


## Current Goal
Automate in-guest configuration of Windows VMs using Ansible to:

Promote designated VMs to Domain Controllers.
Create and configure the AD forest (contoso.com) and optional child domains.
Configure DNS roles and forwarders.
Join member servers and clients to the domain.
Apply additional configurations from the original lab guide (OUs, users, GPOs, trusts).


## Next Steps

Enable WinRM on all Windows VMs for Ansible connectivity.
Build an Ansible project structure:

Inventory with all VM hostnames and IPs.
Group variables for domain details and credentials.
Playbooks for:

Forest creation.
Additional DC promotion.
DNS configuration.
Domain join for clients and servers.
Optional AD objects and GPOs.




Secure credentials using Ansible Vault.
Integrate Terraform outputs into Ansible inventory for dynamic IP resolution.
Validate configuration with dcdiag, repadmin, and DNS resolution tests.


## Key Design Decisions

Region: polandcentral (due to SKU availability).
Provider: AzureRM v4 (to match existing state).
NSG: Restricted RDP access via Bastion subnet or AzureCloud tag.
Secrets: Managed outside of codebase for security.
Idempotency: Both Terraform and Ansible runs should be repeatable without unintended changes.


## Acceptance Criteria

terraform plan shows no changes (clean state).
Ansible playbooks:

Successfully configure AD forest and domains.
Promote all DCs and ensure replication health.
Join all member servers and clients to the domain.
Configure DNS and verify name resolution.


Re-running playbooks results in no changes when the system is in the desired state.…
        