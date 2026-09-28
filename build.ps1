# Checks the Scripter files and builds dist\scripter.zip.
#
#   .\build.ps1            run the checks and build the zip
#   .\build.ps1 -Install   also copy the skill to ~\.claude\skills\scripter
#
# Works in Windows PowerShell 5.1 and PowerShell 7.

param([switch]$Install)

$ErrorActionPreference = 'Stop'
$root     = $PSScriptRoot
$plugin   = Join-Path $root 'scripter'
$skill    = Join-Path $plugin 'skills\scripter'
$skillMd  = Join-Path $skill 'SKILL.md'
$gptFile  = Join-Path $root 'chatgpt\instructions.txt'
$dist     = Join-Path $root 'dist'
$zipPath  = Join-Path $dist 'scripter.zip'

$failures = New-Object System.Collections.Generic.List[string]
function Check([bool]$ok, [string]$what) {
    if ($ok) { Write-Host "  ok    $what" -ForegroundColor Green }
    else     { Write-Host "  FAIL  $what" -ForegroundColor Red; $failures.Add($what) }
}

Write-Host "Checking skill files..."
Check (Test-Path $skillMd) "SKILL.md exists"
$text = [IO.File]::ReadAllText($skillMd)
$fm = [regex]::Match($text, '(?s)^---\r?\n(.*?)\r?\n---')
Check $fm.Success "SKILL.md starts with a frontmatter block"

$name = [regex]::Match($fm.Groups[1].Value, '(?m)^name:\s*(.+?)\s*$').Groups[1].Value
$desc = [regex]::Match($fm.Groups[1].Value, '(?m)^description:\s*(.+?)\s*$').Groups[1].Value.Trim('"', "'")
Check ($name -match '^[a-z0-9-]{1,64}$') "name '$name' uses only a-z, 0-9 and hyphens (max 64)"
Check ($name -eq (Split-Path $skill -Leaf)) "name matches the folder name"
Check ($name -notmatch 'claude|anthropic') "name contains neither 'claude' nor 'anthropic'"
Check ($desc.Length -gt 0 -and $desc.Length -le 200) "description is 1-200 characters (now $($desc.Length))"

$keys = [regex]::Matches($fm.Groups[1].Value, '(?m)^([a-z-]+):') | ForEach-Object { $_.Groups[1].Value }
$allowed = 'name', 'description', 'license', 'compatibility', 'metadata', 'allowed-tools'
$bad = @($keys | Where-Object { $allowed -notcontains $_ })
Check ($bad.Count -eq 0) "frontmatter uses only upload-safe fields ($($keys -join ', '))"

$refs = [regex]::Matches($text, 'references/[\w.-]+\.md') | ForEach-Object { $_.Value } | Sort-Object -Unique
foreach ($r in $refs) { Check (Test-Path (Join-Path $skill $r)) "referenced file $r exists" }

if (Test-Path $gptFile) {
    $gptLen = ([IO.File]::ReadAllText($gptFile)).Length
    Check ($gptLen -le 8000) "chatgpt\instructions.txt is at most 8000 characters (now $gptLen)"
}

Write-Host "Validating plugin and marketplace manifests..."
if (Get-Command claude -ErrorAction SilentlyContinue) {
    & claude plugin validate $plugin | Out-Null
    Check ($LASTEXITCODE -eq 0) "claude plugin validate scripter"
    & claude plugin validate $root | Out-Null
    Check ($LASTEXITCODE -eq 0) "claude plugin validate (marketplace)"
} else {
    Write-Host "  skip  claude CLI not found"
}

Write-Host "Building $zipPath..."
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
New-Item -ItemType Directory -Force $dist | Out-Null
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
# Entries are written by hand so they always use forward slashes and sit under scripter/.
$zip = [IO.Compression.ZipFile]::Open($zipPath, 'Create')
try {
    Get-ChildItem $skill -Recurse -File | ForEach-Object {
        $rel = $_.FullName.Substring($skill.Length + 1).Replace('\', '/')
        [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, "scripter/$rel")
    }
} finally { $zip.Dispose() }

$zip = [IO.Compression.ZipFile]::OpenRead($zipPath)
try { $entries = @($zip.Entries | ForEach-Object { $_.FullName }) } finally { $zip.Dispose() }
Check (@($entries | Where-Object { $_ -notlike 'scripter/*' }).Count -eq 0) "every zip entry is under scripter/"
Check ($entries -contains 'scripter/SKILL.md') "zip contains scripter/SKILL.md"
$entries | ForEach-Object { Write-Host "        $_" }

if ($Install) {
    $target = Join-Path $HOME '.claude\skills\scripter'
    Write-Host "Installing to $target..."
    if (Test-Path $target) { Remove-Item $target -Recurse -Force }
    Copy-Item $skill $target -Recurse
    Check (Test-Path (Join-Path $target 'SKILL.md')) "installed for Claude Code / Claude desktop"
}

if ($failures.Count -gt 0) {
    Write-Host "`n$($failures.Count) check(s) failed." -ForegroundColor Red
    exit 1
}
Write-Host "`nAll checks passed." -ForegroundColor Green
