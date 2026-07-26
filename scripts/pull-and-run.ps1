param(
  [string]$RepositoryDirectory = (Join-Path $HOME "Projects\diff"),
  [string]$Branch = $(if ($env:DIFF_BRANCH) { $env:DIFF_BRANCH } else { "main" }),
  [int]$Port = $(if ($env:DIFF_PORT) { [int]$env:DIFF_PORT } else { 8000 }),
  [string]$Repository = $(if ($env:DIFF_REPOSITORY) { $env:DIFF_REPOSITORY } else { "https://github.com/generalgroovy/diff.git" })
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if ($Branch -notmatch '^[A-Za-z0-9._/-]+$' -or $Branch.StartsWith('-') -or $Branch.Contains('..')) {
  throw "Unsafe Git branch name: $Branch"
}
if ($Port -lt 1 -or $Port -gt 65535) { throw "Port must be from 1 to 65535." }
foreach ($tool in @("git", "node", "npm", "gh")) {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "Missing required command: $tool" }
}

$nodeCompatible = & node -p "const [a,b]=process.versions.node.split('.').map(Number);Number(a>20||(a===20&&b>=19))"
if ($nodeCompatible -ne "1") { throw "DIFF requires Node.js 20.19 or newer." }
& gh auth status --hostname github.com | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Authenticate first: gh auth login --hostname github.com --git-protocol https --web" }
& gh auth setup-git

if (-not (Test-Path $RepositoryDirectory)) {
  New-Item -ItemType Directory -Force -Path (Split-Path $RepositoryDirectory) | Out-Null
  & git clone --origin origin --branch $Branch $Repository $RepositoryDirectory
  if ($LASTEXITCODE -ne 0) { throw "Clone failed." }
} elseif (-not (Test-Path (Join-Path $RepositoryDirectory ".git"))) {
  throw "Refusing to overwrite non-repository directory: $RepositoryDirectory"
}

Push-Location $RepositoryDirectory
try {
  if (& git status --porcelain=v1) { throw "Checkout has uncommitted changes. Commit or stash them first." }
  & git remote set-url origin $Repository
  & git fetch --prune origin $Branch
  if ($LASTEXITCODE -ne 0) { throw "Fetch failed." }
  & git show-ref --verify --quiet "refs/heads/$Branch"
  if ($LASTEXITCODE -eq 0) { & git switch $Branch } else { & git switch --create $Branch --track "origin/$Branch" }
  if ($LASTEXITCODE -ne 0) { throw "Could not select branch $Branch." }
  & git branch --set-upstream-to="origin/$Branch" $Branch
  & git pull --ff-only origin $Branch
  if ($LASTEXITCODE -ne 0) { throw "Fast-forward update refused." }
  & npm ci --ignore-scripts
  if ($LASTEXITCODE -ne 0) { throw "Dependency installation failed." }
  & npm test
  if ($LASTEXITCODE -ne 0) { throw "Tests failed; DIFF was not started." }

  function Test-DiffReady([int]$CandidatePort) {
    try {
      $health = Invoke-RestMethod -Uri "http://127.0.0.1:$CandidatePort/__diff_health" -TimeoutSec 1
      return $health.product -eq "DIFF" -and $health.status -eq "ready" -and $health.version -eq "0.18.0"
    } catch { return $false }
  }
  function Test-PortUsed([int]$CandidatePort) {
    $client = [System.Net.Sockets.TcpClient]::new()
    try { $client.Connect("127.0.0.1", $CandidatePort); return $true } catch { return $false } finally { $client.Dispose() }
  }

  if (Test-PortUsed $Port) {
    if (Test-DiffReady $Port) { Start-Process "http://127.0.0.1:$Port"; return }
    $freePort = $null
    foreach ($candidate in 8001..8100) { if (-not (Test-PortUsed $candidate)) { $freePort = $candidate; break } }
    if ($null -eq $freePort) { throw "No free port from 8000 through 8100." }
    $Port = $freePort
  }

  $env:PORT = [string]$Port
  $env:HOST = $(if ($env:DIFF_HOST) { $env:DIFF_HOST } else { "127.0.0.1" })
  $server = Start-Process -FilePath "npm.cmd" -ArgumentList "start" -WorkingDirectory $RepositoryDirectory -NoNewWindow -PassThru
  try {
    $ready = $false
    foreach ($attempt in 1..50) {
      if ($server.HasExited) { throw "DIFF server exited before becoming ready." }
      if (Test-DiffReady $Port) { $ready = $true; break }
      Start-Sleep -Milliseconds 100
    }
    if (-not $ready) { throw "DIFF did not become ready on port $Port." }
    Write-Host "DIFF is ready at http://127.0.0.1:$Port"
    Start-Process "http://127.0.0.1:$Port"
    Wait-Process -Id $server.Id
  } finally {
    if (-not $server.HasExited) { Stop-Process -Id $server.Id }
  }
} finally {
  Pop-Location
}
