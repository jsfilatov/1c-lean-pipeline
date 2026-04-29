[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('init', 'update', 'add', 'remove', 'doctor', 'eject')]
    [string]$Command = 'doctor',

    [string]$Source = (Get-Location).Path,
    [string[]]$Tools,
    [string]$Tool,
    [switch]$NonInteractive,
    [switch]$AssumeYes
)

$ErrorActionPreference = 'Stop'

$ManifestName = '.1c-lean-pipeline.json'
$ProtocolVersion = '1.0'
$KnownTools = @('cursor', 'claude-code', 'codex', 'opencode', 'kilocode')

function Get-ToolSpec {
    param([string]$Name)

    $specs = @{
        'cursor' = @{
            detection = @('.cursor')
            skill = '.cursor/skills/1c-lean-pipeline'
            rule = '.cursor/rules/code-explorer-rules.mdc'
            agent = '.cursor/agents/1c-code-explorer.md'
            agentMode = 'markdown'
            ruleKeep = @('description', 'globs', 'alwaysApply')
            agentKeep = @('name', 'description', 'tools', 'modelHint', 'allowParallel', 'isSubagent')
            agentRename = @{ modelHint = 'model' }
        }
        'claude-code' = @{
            detection = @('.claude', 'CLAUDE.md')
            skill = '.claude/skills/1c-lean-pipeline'
            rule = '.claude/rules/code-explorer-rules.md'
            agent = '.claude/agents/1c-code-explorer.md'
            agentMode = 'markdown'
            ruleKeep = @('description', 'alwaysApply')
            agentKeep = @('name', 'description', 'tools', 'modelHint', 'isSubagent', 'allowParallel')
            agentRename = @{ modelHint = 'model' }
            entry = 'CLAUDE.md'
            entryTemplate = "See @AGENTS.md for project instructions.`n"
        }
        'codex' = @{
            detection = @('.codex', 'AGENTS.md')
            skill = '.codex/skills/1c-lean-pipeline'
            rule = '.codex/rules/code-explorer-rules.md'
            agent = '.codex/agents/1c-code-explorer.toml'
            agentMode = 'toml'
            ruleKeep = @('description', 'alwaysApply')
        }
        'opencode' = @{
            detection = @('.opencode', 'opencode.json')
            skill = '.opencode/skills/1c-lean-pipeline'
            rule = '.opencode/rules/code-explorer-rules.md'
            agent = '.opencode/agent/1c-code-explorer.md'
            agentMode = 'markdown'
            ruleKeep = @('description', 'alwaysApply')
            agentKeep = @('name', 'description', 'tools', 'modelHint')
            agentRename = @{ modelHint = 'model' }
            agentAddIf = @{ isSubagent = @{ mode = 'subagent' }; '!isSubagent' = @{ mode = 'primary' } }
        }
        'kilocode' = @{
            detection = @('.kilocode')
            skill = '.kilocode/skills/1c-lean-pipeline'
            rule = '.kilocode/rules/code-explorer-rules.md'
            agent = '.kilocode/subagents/1c-code-explorer.md'
            agentMode = 'markdown'
            ruleKeep = @('description', 'alwaysApply')
            agentKeep = @('name', 'description', 'tools', 'modelHint')
            agentRename = @{ modelHint = 'model' }
            agentAddIf = @{ isSubagent = @{ mode = 'subagent' }; '!isSubagent' = @{ mode = 'all' } }
        }
    }

    return $specs[$Name]
}

function Normalize-ToolList {
    param([string[]]$Values)
    $result = New-Object System.Collections.Generic.List[string]
    foreach ($value in $Values) {
        if (-not $value) { continue }
        foreach ($part in ($value -split ',')) {
            $name = $part.Trim()
            if ($name) { $result.Add($name) }
        }
    }
    return @($result)
}

function Assert-Source {
    param([string]$Path)
    $full = (Resolve-Path -LiteralPath $Path).Path
    foreach ($required in @('content/skills/1c-lean-pipeline/SKILL.md', 'content/rules/code-explorer-rules.md', 'content/agents/1c-code-explorer.md')) {
        $candidate = Join-Path $full $required
        if (-not (Test-Path -LiteralPath $candidate)) {
            throw "Source is missing required file: $candidate"
        }
    }
    foreach ($toolName in $KnownTools) {
        $adapter = Join-Path $full ("adapters/{0}.yaml" -f $toolName)
        if ($toolName -eq 'claude-code') {
            $adapter = Join-Path $full 'adapters/claude-code.yaml'
        }
        if (-not (Test-Path -LiteralPath $adapter)) {
            throw "Source is missing adapter: $adapter"
        }
    }
    return $full
}

function Get-ProjectRoot {
    return (Get-Location).Path
}

function Join-ProjectPath {
    param([string]$Root, [string]$Relative)
    return Join-Path $Root ($Relative -replace '/', [IO.Path]::DirectorySeparatorChar)
}

function Get-RelativePath {
    param([string]$Root, [string]$Path)
    $rootFull = [IO.Path]::GetFullPath($Root)
    $pathFull = [IO.Path]::GetFullPath($Path)
    $rootUri = New-Object Uri(($rootFull.TrimEnd([IO.Path]::DirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar))
    $pathUri = New-Object Uri($pathFull)
    return [Uri]::UnescapeDataString($rootUri.MakeRelativeUri($pathUri).ToString()).Replace('\', '/')
}

function Get-FileSha256 {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return $null }
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-TreeSha256 {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        return Get-FileSha256 $Path
    }
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $builder = New-Object System.Text.StringBuilder
    $files = Get-ChildItem -LiteralPath $Path -Recurse -File | Sort-Object FullName
    foreach ($file in $files) {
        $relative = Get-RelativePath $Path $file.FullName
        [void]$builder.Append($relative)
        [void]$builder.Append(':')
        [void]$builder.Append((Get-FileSha256 $file.FullName))
        [void]$builder.Append("`n")
    }
    $bytes = [Text.Encoding]::UTF8.GetBytes($builder.ToString())
    $hash = $sha.ComputeHash($bytes)
    return ([BitConverter]::ToString($hash) -replace '-', '').ToLowerInvariant()
}

function Read-Manifest {
    param([string]$Root)
    $path = Join-Path $Root $ManifestName
    if (-not (Test-Path -LiteralPath $path)) {
        return [pscustomobject]@{
            protocolVersion = $ProtocolVersion
            source = $null
            installedAt = $null
            tools = @()
            files = @()
            foreignFiles = @()
        }
    }
    return Get-Content -LiteralPath $path -Raw | ConvertFrom-Json
}

function Write-Manifest {
    param([string]$Root, [object]$Manifest)
    $path = Join-Path $Root $ManifestName
    $Manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $path -Encoding UTF8
}

function Test-OwnedTarget {
    param([object]$Manifest, [string]$ToolName, [string]$Target)
    foreach ($file in @($Manifest.files)) {
        if ($file.tool -eq $ToolName -and $file.target -eq $Target) { return $true }
    }
    return $false
}

function Add-ForeignFile {
    param([object]$Manifest, [string]$ToolName, [string]$Target)
    $existing = @($Manifest.foreignFiles) | Where-Object { $_.tool -eq $ToolName -and $_.target -eq $Target }
    if (-not $existing) {
        $Manifest.foreignFiles = @(@($Manifest.foreignFiles) + [pscustomobject]@{
            tool = $ToolName
            target = $Target
            detectedAt = (Get-Date).ToString('o')
        })
    }
}

function Confirm-Overwrite {
    param([string]$Target)
    if ($AssumeYes) { return $true }
    if ($NonInteractive) { return $false }
    $answer = Read-Host "Overwrite existing unmanaged file or directory '$Target'? [y/N]"
    return $answer -match '^(y|yes|д|да)$'
}

function Read-FrontmatterDocument {
    param([string]$Path)
    $text = Get-Content -LiteralPath $Path -Raw
    $pattern = "(?s)^---\s*\r?\n(.*?)\r?\n---\s*\r?\n(.*)$"
    $match = [regex]::Match($text, $pattern)
    if (-not $match.Success) {
        return [pscustomobject]@{ frontmatter = @{}; body = $text }
    }
    $map = @{}
    foreach ($line in ($match.Groups[1].Value -split "\r?\n")) {
        if (-not $line.Trim()) { continue }
        $idx = $line.IndexOf(':')
        if ($idx -lt 0) { continue }
        $key = $line.Substring(0, $idx).Trim()
        $value = $line.Substring($idx + 1).Trim()
        $map[$key] = $value
    }
    return [pscustomobject]@{ frontmatter = $map; body = $match.Groups[2].Value }
}

function ConvertTo-MarkdownDocument {
    param(
        [object]$Doc,
        [string[]]$Keep,
        [hashtable]$Rename,
        [hashtable]$AddIf
    )
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($key in $Keep) {
        if (-not $Doc.frontmatter.ContainsKey($key)) { continue }
        $targetKey = $key
        if ($Rename -and $Rename.ContainsKey($key)) { $targetKey = $Rename[$key] }
        $lines.Add(("{0}: {1}" -f $targetKey, $Doc.frontmatter[$key]))
    }
    if ($AddIf) {
        foreach ($condition in $AddIf.Keys) {
            $negated = $condition.StartsWith('!')
            $sourceKey = $condition.TrimStart('!')
            $exists = $Doc.frontmatter.ContainsKey($sourceKey) -and ($Doc.frontmatter[$sourceKey] -eq 'true')
            if (($exists -and -not $negated) -or (-not $exists -and $negated)) {
                foreach ($entry in $AddIf[$condition].GetEnumerator()) {
                    $lines.Add(("{0}: {1}" -f $entry.Key, $entry.Value))
                }
            }
        }
    }
    return "---`n$($lines -join "`n")`n---`n$($Doc.body)"
}

function ConvertTo-CodexToml {
    param([object]$Doc)
    $name = ($Doc.frontmatter['name'] -replace '"', '\"')
    $description = ($Doc.frontmatter['description'] -replace '"', '\"')
    $model = 'inherit'
    if ($Doc.frontmatter.ContainsKey('modelHint')) { $model = ($Doc.frontmatter['modelHint'] -replace '"', '\"') }
    $body = $Doc.body -replace '"""', '\"\"\"'
    return "name = `"$name`"`ndescription = `"$description`"`nmodel = `"$model`"`ndeveloper_instructions = `"`"`"`n$body`n`"`"`"`n"
}

function Set-ManagedFile {
    param(
        [string]$Root,
        [object]$Manifest,
        [string]$ToolName,
        [string]$SourceRel,
        [string]$TargetRel,
        [string]$Content
    )
    $target = Join-ProjectPath $Root $TargetRel
    $owned = Test-OwnedTarget $Manifest $ToolName $TargetRel
    if ((Test-Path -LiteralPath $target) -and -not $owned) {
        if (-not (Confirm-Overwrite $TargetRel)) {
            Add-ForeignFile $Manifest $ToolName $TargetRel
            Write-Warning "Skipped unmanaged target: $TargetRel"
            return
        }
    }
    $parent = Split-Path -Parent $target
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $target -Value $Content -Encoding UTF8
    Add-ManifestFile $Manifest $ToolName $SourceRel $TargetRel (Get-FileSha256 $target)
}

function Copy-ManagedDirectory {
    param(
        [string]$Root,
        [string]$SourceRoot,
        [object]$Manifest,
        [string]$ToolName,
        [string]$SourceRel,
        [string]$TargetRel
    )
    $source = Join-Path $SourceRoot ($SourceRel -replace '/', [IO.Path]::DirectorySeparatorChar)
    $target = Join-ProjectPath $Root $TargetRel
    $owned = Test-OwnedTarget $Manifest $ToolName $TargetRel
    if ((Test-Path -LiteralPath $target) -and -not $owned) {
        if (-not (Confirm-Overwrite $TargetRel)) {
            Add-ForeignFile $Manifest $ToolName $TargetRel
            Write-Warning "Skipped unmanaged target: $TargetRel"
            return
        }
    }
    $parent = Split-Path -Parent $target
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
    }
    Copy-Item -LiteralPath $source -Destination $target -Recurse
    Add-ManifestFile $Manifest $ToolName $SourceRel $TargetRel (Get-TreeSha256 $target)
}

function Add-ManifestFile {
    param([object]$Manifest, [string]$ToolName, [string]$SourceRel, [string]$TargetRel, [string]$Sha256)
    $kept = @($Manifest.files) | Where-Object { -not ($_.tool -eq $ToolName -and $_.target -eq $TargetRel) }
    $Manifest.files = @(@($kept) + [pscustomobject]@{
        tool = $ToolName
        source = $SourceRel
        target = $TargetRel
        sha256 = $Sha256
    })
}

function Detect-Tools {
    param([string]$Root)
    $detected = New-Object System.Collections.Generic.List[string]
    foreach ($toolName in $KnownTools) {
        $spec = Get-ToolSpec $toolName
        foreach ($path in $spec.detection) {
            if (Test-Path -LiteralPath (Join-ProjectPath $Root $path)) {
                $detected.Add($toolName)
                break
            }
        }
    }
    return @($detected)
}

function Resolve-SelectedTools {
    param([string]$Root, [string[]]$ExplicitTools)
    $selected = Normalize-ToolList $ExplicitTools
    if ($Tool -and $Command -eq 'add') { $selected = @($Tool) }
    if ($selected.Count -eq 0) { $selected = Detect-Tools $Root }
    if ($selected.Count -eq 0) {
        if ($NonInteractive) { throw "No active tools detected. Pass -Tools cursor,claude-code,codex,opencode,kilocode." }
        $answer = Read-Host "No AI tool directory detected. Which tools should I install for? (cursor, claude-code, codex, opencode, kilocode)"
        $selected = Normalize-ToolList @($answer)
    }
    foreach ($name in $selected) {
        if ($KnownTools -notcontains $name) { throw "Unknown tool: $name" }
    }
    return @($selected | Select-Object -Unique)
}

function Install-Tool {
    param([string]$Root, [string]$SourceRoot, [object]$Manifest, [string]$ToolName)
    $spec = Get-ToolSpec $ToolName

    Copy-ManagedDirectory $Root $SourceRoot $Manifest $ToolName 'content/skills/1c-lean-pipeline' $spec.skill

    $ruleDoc = Read-FrontmatterDocument (Join-Path $SourceRoot 'content/rules/code-explorer-rules.md')
    $ruleContent = ConvertTo-MarkdownDocument $ruleDoc $spec.ruleKeep @{} $null
    Set-ManagedFile $Root $Manifest $ToolName 'content/rules/code-explorer-rules.md' $spec.rule $ruleContent

    $agentDoc = Read-FrontmatterDocument (Join-Path $SourceRoot 'content/agents/1c-code-explorer.md')
    if ($spec.agentMode -eq 'toml') {
        $agentContent = ConvertTo-CodexToml $agentDoc
    } else {
        $agentContent = ConvertTo-MarkdownDocument $agentDoc $spec.agentKeep $spec.agentRename $spec.agentAddIf
    }
    Set-ManagedFile $Root $Manifest $ToolName 'content/agents/1c-code-explorer.md' $spec.agent $agentContent

    if ($spec.ContainsKey('entry')) {
        $entryPath = Join-ProjectPath $Root $spec.entry
        if (-not (Test-Path -LiteralPath $entryPath)) {
            Set-ManagedFile $Root $Manifest $ToolName '<generated-entry>' $spec.entry $spec.entryTemplate
        } else {
            Add-ForeignFile $Manifest $ToolName $spec.entry
        }
    }
}

function Remove-Managed {
    param([string]$Root, [object]$Manifest, [string]$OnlyTool)
    $remaining = New-Object System.Collections.Generic.List[object]
    foreach ($file in @($Manifest.files)) {
        if ($OnlyTool -and $file.tool -ne $OnlyTool) {
            $remaining.Add($file)
            continue
        }
        $target = Join-ProjectPath $Root $file.target
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
            Write-Host "Removed $($file.target)"
        }
    }
    $Manifest.files = @($remaining.ToArray())
    if ($OnlyTool) {
        $Manifest.tools = @($Manifest.tools) | Where-Object { $_ -ne $OnlyTool }
    } else {
        $Manifest.tools = @()
    }
}

function Invoke-Doctor {
    param([string]$Root, [string]$SourceRoot, [string[]]$SelectedTools)
    Write-Host "Project: $Root"
    if ($SourceRoot) { Write-Host "Source:  $SourceRoot" }
    $detected = Detect-Tools $Root
    Write-Host ("Detected tools: " + (($detected -join ', ') -replace '^$', '<none>'))
    if ($SelectedTools -and $SelectedTools.Count -gt 0) {
        Write-Host ("Selected tools: " + ($SelectedTools -join ', '))
    }
    $manifestPath = Join-Path $Root $ManifestName
    if (Test-Path -LiteralPath $manifestPath) {
        $manifest = Read-Manifest $Root
        Write-Host ("Manifest tools: " + (@($manifest.tools) -join ', '))
        foreach ($file in @($manifest.files)) {
            $target = Join-ProjectPath $Root $file.target
            $status = 'missing'
            if (Test-Path -LiteralPath $target) { $status = 'present' }
            Write-Host ("[{0}] {1} -> {2}" -f $status, $file.tool, $file.target)
        }
    } else {
        Write-Host "Manifest: missing"
    }
}

$ProjectRoot = Get-ProjectRoot

if ($Command -eq 'eject') {
    $manifestPath = Join-Path $ProjectRoot $ManifestName
    if (Test-Path -LiteralPath $manifestPath) {
        Remove-Item -LiteralPath $manifestPath -Force
        Write-Host "Removed $ManifestName"
    }
    return
}

if ($Command -eq 'remove') {
    $manifest = Read-Manifest $ProjectRoot
    Remove-Managed $ProjectRoot $manifest $Tool
    if (@($manifest.files).Count -eq 0) {
        $manifestPath = Join-Path $ProjectRoot $ManifestName
        if (Test-Path -LiteralPath $manifestPath) { Remove-Item -LiteralPath $manifestPath -Force }
    } else {
        Write-Manifest $ProjectRoot $manifest
    }
    return
}

$SourceRoot = Assert-Source $Source
$SelectedTools = Resolve-SelectedTools $ProjectRoot $Tools

if ($Command -eq 'doctor') {
    Invoke-Doctor $ProjectRoot $SourceRoot $SelectedTools
    return
}

$manifest = Read-Manifest $ProjectRoot
$manifest.protocolVersion = $ProtocolVersion
$manifest.source = $SourceRoot
$manifest.installedAt = (Get-Date).ToString('o')

foreach ($toolName in $SelectedTools) {
    Install-Tool $ProjectRoot $SourceRoot $manifest $toolName
}

$manifest.tools = @(@($manifest.tools) + $SelectedTools | Select-Object -Unique)
Write-Manifest $ProjectRoot $manifest
Write-Host ("Installed 1c-lean-pipeline for: " + ($SelectedTools -join ', '))
