# (Re)creates the trigger-only eval cases in scripter\evals-trigger\. Safe to re-run.
$ErrorActionPreference = 'Stop'
$root = Join-Path (Split-Path $PSScriptRoot -Parent) 'scripter\evals-trigger'
$cases = [ordered]@{
  'p01-invented-bike'        = @('positive', 'I invented a bike that charges your phone while you ride. Check if it works.')
  'p02-drone-never-lands'    = @('positive', 'is it possible to make a drone that never lands')
  'p03-3d-laptop-stand'      = @('positive', 'make me a 3D model of a folding laptop stand')
  'p04-shelf-hold'           = @('positive', 'will a 12 mm plywood shelf hold 20 kg over 80 cm?')
  'p05-plant-app'            = @('positive', 'design an app that tells me when my plants need water')
  'p06-mug-handle-inside'    = @('positive', "what's wrong with my design: a coffee mug with the handle inside the cup")
  'p07-backpack-umbrella'    = @('positive', 'improve this: a backpack with a built-in umbrella arm')
  'p08-sketch-lamp'          = @('positive', 'turn my 2d sketch of a lamp into 3d')
  'p09-leafblower-hovercraft'= @('positive', 'can I build a hovercraft with a leaf blower?')
  'p10-pi-case'              = @('positive', 'how should I make a waterproof case for a Raspberry Pi?')
  'p11-solar-car-roof'       = @('positive', 'check my idea: solar panels on the roof of a car to power it')
  'p12-typo-washer'          = @('positive', 'desgin me a beter washing machin that uses less water')
  'p13-usb-fridge'           = @('positive', 'i want to build a mini fridge powered by a peltier from a usb port')
  'p14-kitchen-layout'       = @('positive', 'redesign my kitchen so the fridge is next to the oven')
  'p15-imperial-2x4'         = @('positive', 'will a 2x4 hold 300 lbs in the middle over a 10 ft span?')
  'n01-poem'                 = @('negative', 'Write a short poem about autumn.')
  'n02-python-error'         = @('negative', "Fix this Python error: TypeError: 'NoneType' object is not subscriptable")
  'n03-summary'              = @('negative', 'Summarize the plot of Romeo and Juliet in 3 sentences.')
  'n04-landlord-email'       = @('negative', 'Write an email asking my landlord to fix the heating.')
  'n05-recipe'               = @('negative', 'Give me a recipe for banana bread.')
  'n06-trivia'               = @('negative', "What's the capital of Australia?")
  'n07-powershell-script'    = @('negative', 'Write a PowerShell script that renames all .txt files in a folder to .md.')
  'n08-video-script'         = @('negative', 'Write a script for a 30-second YouTube intro.')
  'n09-logo'                 = @('negative', 'Design a logo for my bakery.')
}
$front = @'
---
tags: [trigger, {0}]
max_turns: 4
timeout_seconds: 180
allowed_tools: [Read, Glob, Grep, Skill]
---

{1}
'@
$fired = @'
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?scripter"'
---
'@
$notFired = @'
---
type: tool_used
tool: Skill
input_match: '"skill"\s*:\s*"(?:[\w-]+:)?scripter"'
min: 0
max: 0
arm: both
---
'@
foreach ($name in $cases.Keys) {
  $kind, $prompt = $cases[$name]
  $dir = Join-Path $root $name
  New-Item -ItemType Directory -Force (Join-Path $dir 'graders') | Out-Null
  ($front -f $kind, $prompt) | Set-Content (Join-Path $dir 'prompt.md') -Encoding utf8
  if ($kind -eq 'positive') { $fired    | Set-Content (Join-Path $dir 'graders\skill-fired.md') -Encoding utf8 }
  else                      { $notFired | Set-Content (Join-Path $dir 'graders\skill-not-fired.md') -Encoding utf8 }
}
Write-Host "Wrote $($cases.Count) trigger cases to $root"
