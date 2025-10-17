# Define the base path
$basePath = "ansible"

# Define the folder structure
$folders = @(
    "$basePath/inventory",
    "$basePath/group_vars",
    "$basePath/host_vars",
    "$basePath/roles/bootstrap-winrm/tasks",
    "$basePath/roles/ad-forest/tasks",
    "$basePath/roles/ad-additional-dc/tasks",
    "$basePath/roles/dns-config/tasks",
    "$basePath/roles/domain-join/tasks",
    "$basePath/roles/ad-objects/tasks",
    "$basePath/roles/gpos/tasks",
    "$basePath/roles/trusts/tasks",
    "$basePath/playbooks",
    "$basePath/files/scripts",
    "$basePath/templates",
    "$basePath/tools"
)

# Define the files to create
$files = @(
    "$basePath/inventory/hosts.yml",
    "$basePath/group_vars/all.yml",
    "$basePath/host_vars/ContosoDC1.yml",
    "$basePath/roles/bootstrap-winrm/tasks/main.yml",
    "$basePath/roles/ad-forest/tasks/main.yml",
    "$basePath/roles/ad-additional-dc/tasks/main.yml",
    "$basePath/roles/dns-config/tasks/main.yml",
    "$basePath/roles/domain-join/tasks/main.yml",
    "$basePath/roles/ad-objects/tasks/main.yml",
    "$basePath/roles/gpos/tasks/main.yml",
    "$basePath/roles/trusts/tasks/main.yml",
    "$basePath/playbooks/bootstrap-winrm.yml",
    "$basePath/playbooks/ad-forest.yml",
    "$basePath/playbooks/ad-additional-dc.yml",
    "$basePath/playbooks/dns-config.yml",
    "$basePath/playbooks/domain-join.yml",
    "$basePath/playbooks/ad-objects.yml",
    "$basePath/playbooks/gpos.yml",
    "$basePath/playbooks/trusts.yml",
    "$basePath/files/scripts/enable-winrm-https.ps1",
    "$basePath/templates/inventory.tpl.j2",
    "$basePath/tools/tf_to_inventory.py"
)

# Create folders
foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
}

# Create files
foreach ($file in $files) {
    New-Item -ItemType File -Path $file -Force | Out-Null
}

Write-Host "Ansible folder structure created successfully at $basePath"