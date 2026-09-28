# Checks whether Scripter fires when the user's own skills and plugins are loaded too
# (the eval sandbox leaves those out). MCP servers are not loaded, so nothing outside the
# prompt can be touched, and file-writing tools are blocked.
#   .\tools\real-env-trigger.ps1 [-Snippet <text>] [-Out <file>] [-Model sonnet]
param(
  [string]$Snippet,
  [string]$Out = (Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter\evals\results\05-real-env.md'),
  [string]$Model = 'sonnet',
  [string]$WorkDir = (Join-Path $env:TEMP 'scripter-real-env')
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [Text.Encoding]::UTF8
$OutputEncoding = [Text.Encoding]::UTF8
$pluginDir = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter'
$prompts = [ordered]@{
  p01 = 'I invented a bike that charges your phone while you ride. Check if it works.'
  p03 = 'make me a 3D model of a folding laptop stand'
  p05 = 'design an app that tells me when my plants need water'
  p09 = 'can I build a hovercraft with a leaf blower?'
  p12 = 'desgin me a beter washing machin that uses less water'
  p14 = 'redesign my kitchen so the fridge is next to the oven'
  n02 = "Fix this Python error: TypeError: 'NoneType' object is not subscriptable"
  n07 = 'Write a PowerShell script that renames all .txt files in a folder to .md.'
  n08 = 'Write a script for a 30-second YouTube intro.'
}
New-Item -ItemType Directory -Force $WorkDir | Out-Null
$common = @('-p', '--output-format', 'stream-json', '--verbose', '--plugin-dir', $pluginDir, '--model', $Model,
            '--no-session-persistence', '--strict-mcp-config', '--permission-mode', 'dontAsk',
            '--disallowedTools', 'Write,Edit,Bash,PowerShell,NotebookEdit')
if ($Snippet) { $common += @('--append-system-prompt', $Snippet) }
Push-Location $WorkDir
try {
  $available = $null
  $rows = foreach ($id in $prompts.Keys) {
    Write-Host "running $id"
    $raw = $prompts[$id] | & claude @common
    $skills = @(foreach ($line in $raw) {
      try { $e = $line | ConvertFrom-Json } catch { continue }
      if ($e.type -eq 'system' -and $e.subtype -eq 'init' -and -not $available) { $available = $e.skills }
      if ($e.type -eq 'assistant') {
        foreach ($c in $e.message.content) { if ($c.type -eq 'tool_use' -and $c.name -eq 'Skill') { $c.input.skill } }
      }
    }) | Select-Object -Unique
    [pscustomobject]@{
      Id       = $id
      Expect   = $(if ($id -like 'p*') { 'fire' } else { 'none' })
      Skills   = ($skills -join ' > ')
      Scripter = [bool]($skills | Where-Object { $_ -match '(^|:)scripter$' })
    }
  }
} finally { Pop-Location }
$rows | Format-Table -AutoSize
"Skills available in the session: $(@($available).Count)"
$md = "| Id | Expect | Skills fired (in order) | Scripter fired |`n|---|---|---|---|`n" +
      (($rows | ForEach-Object { "| $($_.Id) | $($_.Expect) | $($_.Skills) | $($_.Scripter) |" }) -join "`n") +
      "`n`nSkills available: $(@($available) -join ', ')`n"
$md | Set-Content $Out -Encoding utf8
