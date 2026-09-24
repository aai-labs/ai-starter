param(
    [string]$TargetPath = "."
)

$sourceRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$targetRoot = Resolve-Path $TargetPath
$files = "AGENTS.md", "INIT.md", "CODE_GUIDELINES.md", "WEBAPP_GUIDELINES.md", "TESTING.md", "CHANGELOG.md", "docs/INDEX.md", "docs/DOCUMENTATION_BLUEPRINT.md"

foreach ($file in $files) {
    $source = Join-Path $sourceRoot $file
    $target = Join-Path $targetRoot $file

    if (Test-Path $target) {
        Write-Host "skip $file (already exists)"
        continue
    }

    $targetParent = Split-Path -Parent $target
    if (-not (Test-Path $targetParent)) { New-Item -ItemType Directory -Path $targetParent -Force | Out-Null }
    Copy-Item $source $target
    Write-Host "added $file"
}
