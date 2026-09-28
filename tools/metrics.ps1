# Summarises claude plugin eval results: one row per case per arm.
#   .\tools\metrics.ps1 -ResultDirs <dir>[,<dir>...] [-Out <file.md>]
# Chars = mean length of the final reply, taken from the llm graders' evidence (the last message).
param(
  [Parameter(Mandatory)][string[]]$ResultDirs,
  [string]$Out
)
$ErrorActionPreference = 'Stop'

# A "run" is any object in the result JSON that has both graders and costUsd.
function Get-Runs($node) {
  if ($null -eq $node) { return }
  if ($node -is [System.Array]) { foreach ($n in $node) { Get-Runs $n }; return }
  if ($node -is [pscustomobject]) {
    $names = $node.PSObject.Properties.Name
    if ($names -contains 'graders' -and $names -contains 'costUsd') { return $node }
    foreach ($p in $node.PSObject.Properties) { Get-Runs $p.Value }
  }
}

function Get-ReplyChars($run) {
  $ev = @($run.graders | Where-Object { $_.judgeVotes -and $_.evidence } | ForEach-Object { $_.evidence.Length })
  if ($ev) { ($ev | Measure-Object -Maximum).Maximum } else { $null }
}

$rows = foreach ($dir in $ResultDirs) {
  $agg = Get-Content (Join-Path $dir 'aggregate-result.json') -Raw -Encoding utf8 | ConvertFrom-Json
  foreach ($case in $agg.cases) {
    foreach ($arm in $case.arms.PSObject.Properties) {
      $runs = @(Get-Runs $arm.Value)
      if (-not $runs) { continue }
      $fired = @($runs | Where-Object {
        $g = $_.graders
        ($g | Where-Object { $_.name -eq 'skill-fired' -and $_.passed }) -or
        ($g | Where-Object { $_.name -eq 'skill-not-fired' -and -not $_.passed })
      }).Count
      $chars = @($runs | ForEach-Object { Get-ReplyChars $_ } | Where-Object { $_ })
      # "Pass" = every scored grader passed (the with-only skill-fired indicator doesn't count).
      $passCount = @($runs | Where-Object { -not ($_.graders | Where-Object { $_.scored -ne $false -and -not $_.passed }) }).Count
      [pscustomobject]@{
        Run     = Split-Path $dir -Leaf
        Case    = $case.name
        Arm     = $arm.Name
        Score   = [math]::Round(($runs | Measure-Object score -Average).Average, 2)
        Pass    = '{0}/{1}' -f $passCount, $runs.Count
        Fired   = '{0}/{1}' -f $fired, $runs.Count
        CostUsd = [math]::Round(($runs | Measure-Object costUsd -Sum).Sum + ($runs | Measure-Object judgeCostUsd -Sum).Sum, 3)
        Chars   = $(if ($chars) { [math]::Round(($chars | Measure-Object -Average).Average) } else { '' })
      }
    }
  }
}
$rows | Format-Table -AutoSize | Out-String -Width 200
'Total cost: $' + [math]::Round(($rows | Measure-Object CostUsd -Sum).Sum, 2)
if ($Out) {
  $md = "| Run | Case | Arm | Score | Pass | Fired | Cost $ | Chars |`n|---|---|---|---|---|---|---|---|`n" +
        (($rows | ForEach-Object { "| $($_.Run) | $($_.Case) | $($_.Arm) | $($_.Score) | $($_.Pass) | $($_.Fired) | $($_.CostUsd) | $($_.Chars) |" }) -join "`n")
  $md | Set-Content $Out -Encoding utf8
}
