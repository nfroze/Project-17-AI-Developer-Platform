# PowerShell script for Windows
Write-Host "🧹 Tearing down AI Platform..." -ForegroundColor Yellow

Set-Location terraform
terraform destroy -auto-approve

Write-Host "✅ Teardown complete!" -ForegroundColor Green
Set-Location ..