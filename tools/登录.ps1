# 用 Personal Access Token 登录 GitHub（设备码流程被网络拦截时的替代方案）
# 生成 token: https://github.com/settings/tokens/new?scopes=repo&description=CAM350-Slim
# 用法:
#   .\tools\登录.ps1
#   .\tools\登录.ps1 -Token ghp_xxx

param(
    [string]$Token = ""
)

$ErrorActionPreference = "Stop"

$ghExe = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghExe)) {
    $c = Get-Command gh -ErrorAction SilentlyContinue
    if ($c) { $ghExe = $c.Source } else { throw "gh not found, run: winget install --id GitHub.cli -e" }
}

if (-not $Token) {
    $sec = Read-Host "Paste GitHub PAT" -AsSecureString
    $Token = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
}
$Token = $Token.Trim()
if ($Token.Length -lt 20) { throw "token too short" }

$tmp = Join-Path $env:TEMP "gh_token.txt"
Set-Content -LiteralPath $tmp -Value $Token -Encoding ASCII -NoNewline
try {
    Get-Content -LiteralPath $tmp -Raw | & $ghExe auth login --hostname github.com --git-protocol https --with-token
    if ($LASTEXITCODE -ne 0) { throw "gh auth login failed (invalid token or scope)" }
} finally {
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

& $ghExe auth setup-git
$login = (& $ghExe api user --jq .login).Trim()
Write-Host ""
Write-Host "LOGIN OK: $login" -ForegroundColor Green
& $ghExe auth status
Write-Host ""
Write-Host "next: cd D:\GitHub\CAM350_Slim ; .\tools\发布.ps1 -RepoOwner $login"
