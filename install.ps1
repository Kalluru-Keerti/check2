# install.ps1 — Global install for IBM Pre-Sales Demo Builder (Windows)
# Merges mode, skills, rules, and MCP config into %USERPROFILE%\.bob\
# Safe: merges rather than overwrites existing config. Idempotent.

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BobDir    = "$env:USERPROFILE\.bob"
$SrcBob    = Join-Path $ScriptDir ".bob"
$Slug      = "ibm-presales-demo-builder"

Write-Host ""
Write-Host "IBM Pre-Sales Demo Builder - Global Install"
Write-Host "============================================"
Write-Host ""

# 1. Create required directories
Write-Host "-> Creating Bob directories..."
New-Item -ItemType Directory -Force -Path "$BobDir\skills" | Out-Null
New-Item -ItemType Directory -Force -Path "$BobDir\rules"  | Out-Null
Write-Host "   OK"

# 2. Merge custom_modes.yaml
Write-Host "-> Merging custom_modes.yaml..."
$ModesSrc  = Join-Path $SrcBob "custom_modes.yaml"
$ModesDest = Join-Path $BobDir  "custom_modes.yaml"

if (-not (Test-Path $ModesDest)) {
    # No global file yet — copy directly
    Copy-Item $ModesSrc $ModesDest
    Write-Host "   custom_modes.yaml created."
} elseif (Select-String -Path $ModesDest -Pattern $Slug -Quiet) {
    Write-Host "   Mode '$Slug' already present - skipping."
} else {
    # Append mode entries, stripping the top-level 'customModes:' key
    # to avoid a duplicate YAML key in the merged file
    $lines = Get-Content $ModesSrc | Where-Object { $_ -notmatch "^customModes:" }
    Add-Content -Path $ModesDest -Value ""
    Add-Content -Path $ModesDest -Value $lines
    Write-Host "   Mode appended to existing custom_modes.yaml."
}

# 3. Merge mcp_settings.json
Write-Host "-> Merging mcp_settings.json..."
$McpSrc  = Join-Path $SrcBob "mcp.json"
$McpDest = Join-Path $BobDir  "mcp_settings.json"

$srcObj = Get-Content $McpSrc -Raw | ConvertFrom-Json
$srcServers = $srcObj.mcpServers

if (Test-Path $McpDest) {
    $destObj = Get-Content $McpDest -Raw | ConvertFrom-Json
} else {
    $destObj = [PSCustomObject]@{ mcpServers = [PSCustomObject]@{} }
}

if ($null -eq $destObj.mcpServers) {
    $destObj | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue ([PSCustomObject]@{}) -Force
}

# Merge: existing entries take precedence on key conflict
$srcServers.PSObject.Properties | ForEach-Object {
    $key = $_.Name
    if (-not ($destObj.mcpServers.PSObject.Properties.Name -contains $key)) {
        $destObj.mcpServers | Add-Member -NotePropertyName $key -NotePropertyValue $_.Value -Force
    }
}

$destObj | ConvertTo-Json -Depth 10 | Set-Content -Path $McpDest -Encoding UTF8
Write-Host "   mcp_settings.json merged."

# 4. Copy skills (overwrite — package is authoritative for its own skills)
Write-Host "-> Copying skills..."
$skillsSrc = Join-Path $SrcBob "skills"
Get-ChildItem -Path $skillsSrc -Directory | ForEach-Object {
    $dest = Join-Path "$BobDir\skills" $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
}
Write-Host "   Skills copied."

# 5. Copy rules
Write-Host "-> Copying rules..."
$rulesSrc = Join-Path $SrcBob "rules"
Get-ChildItem -Path $rulesSrc -Directory | ForEach-Object {
    $dest = Join-Path "$BobDir\rules" $_.Name
    Copy-Item -Path $_.FullName -Destination $dest -Recurse -Force
}
Write-Host "   Rules copied."

Write-Host ""
Write-Host "Done - restart Bob to activate the IBM Pre-Sales Demo Builder mode."
Write-Host ""
