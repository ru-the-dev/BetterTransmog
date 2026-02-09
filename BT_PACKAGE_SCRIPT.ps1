# BT_PACKAGE_SCRIPT.ps1
# Activates a virtual environment (if found) and runs the changelog updater
# followed by the package script.

$ErrorActionPreference = 'Stop'

$activated = $false
$venvCandidates = @('.venv\Scripts\Activate.ps1','venv\Scripts\Activate.ps1')
foreach ($candidate in $venvCandidates) {
	if (Test-Path $candidate) {
		Write-Host "Activating virtual environment: $candidate"
		. $candidate
		$activated = $true
		break
	}
}

if (-not $activated) {
	Write-Host "No virtual environment found (looked for .venv and venv). Continuing without activation." -ForegroundColor Yellow
}

Write-Host "Running changelog updater..."
py .\Libs\LibRu\ChangeLog\update_changelog.py .\CHANGELOG.md .\Modules\ChangeLog.lua
if ($LASTEXITCODE -ne 0) {
	Write-Error "update_changelog.py failed with exit code $LASTEXITCODE"
	exit $LASTEXITCODE
}

Write-Host "Running package.py..."
py .\package.py
if ($LASTEXITCODE -ne 0) {
	Write-Error "package.py failed with exit code $LASTEXITCODE"
	exit $LASTEXITCODE
}

Write-Host "BT package script completed successfully."