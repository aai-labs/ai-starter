param(
    [string]$RequestedBase = ''
)

$ErrorActionPreference = 'Stop'

function Test-GitRef {
    param([Parameter(Mandatory = $true)][string]$Ref)
    git rev-parse --verify $Ref *> $null
    return $LASTEXITCODE -eq 0
}

$Base = ''

if ($RequestedBase) {
    $Base = $RequestedBase
} elseif (Test-GitRef -Ref 'origin/main') {
    $Base = 'origin/main'
} elseif (Test-GitRef -Ref 'origin/master') {
    $Base = 'origin/master'
} else {
    $remoteInfo = git remote show origin 2>$null
    $headLine = $remoteInfo | Select-String -Pattern 'HEAD branch:' | Select-Object -First 1
    if ($headLine) {
        $defaultBranch = ($headLine.ToString().Split(':')[-1]).Trim()
        if ($defaultBranch) {
            $Base = "origin/$defaultBranch"
        }
    }
}

if (-not $Base) {
    Write-Host "Could not determine base branch."
    Write-Host "Pass a base branch explicitly, for example:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .agents/skills/review-branch-diff/scripts/collect-review-context.ps1 origin/main"
    exit 1
}

if (-not (Test-GitRef -Ref $Base)) {
    Write-Host "Base branch '$Base' is not a valid ref in this repository."
    Write-Host "Pass an existing base branch explicitly."
    exit 1
}

Write-Host "## Current branch"
git branch --show-current

Write-Host ""
Write-Host "## Base branch"
Write-Host $Base

Write-Host ""
Write-Host "## Working tree status"
git status --short

Write-Host ""
Write-Host "## Merge base"
git merge-base HEAD $Base

Write-Host ""
Write-Host "## Diff stat"
git diff --stat "$Base...HEAD"

Write-Host ""
Write-Host "## Changed files"
git diff --name-status "$Base...HEAD"

Write-Host ""
Write-Host "## Recent commits on this branch"
git log --oneline "$Base..HEAD"

Write-Host ""
Write-Host "## Full diff"
git diff --find-renames "$Base...HEAD"