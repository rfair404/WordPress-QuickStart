# WordPress E-commerce Starter - PowerShell Profile
# Add this to your PowerShell profile for enhanced development experience

# Project paths
$env:WQS_PROJECT_ROOT = "C:\Users\Reuseum\na\scripts\setup\..\.."
$env:PATH += ";C:\Users\Reuseum\na\scripts\setup\..\..\scripts;C:\Users\Reuseum\na\scripts\setup\..\..\scripts\setup"

# Development aliases
function lando-start { lando start }
function lando-stop { lando stop }
function lando-restart { lando restart }
function lando-info { lando info }
function dev-setup { lando composer dev:setup; lando npm install }
function dev-test { lando composer test; lando npm test }
function dev-lint { lando composer lint; lando npm run lint:js }
function dev-format { lando npm run format:all }

# Navigation functions
function goto-src { Set-Location "$env:WQS_PROJECT_ROOT\src" }
function goto-tests { Set-Location "$env:WQS_PROJECT_ROOT\tests" }
function goto-scripts { Set-Location "$env:WQS_PROJECT_ROOT\scripts" }
function goto-root { Set-Location "$env:WQS_PROJECT_ROOT" }

Write-Host "🚀 WordPress E-commerce Starter environment loaded" -ForegroundColor Green
