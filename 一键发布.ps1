# 一键发布：登录 -> 定位/创建仓库 -> 推送 -> 建 Release -> 上传两个 255MB 附件
# 用法（在 D:\GitHub\CAM350_Slim 下）：
#   powershell -ExecutionPolicy Bypass -File .\一键发布.ps1
#   powershell -ExecutionPolicy Bypass -File .\一键发布.ps1 -RepoName CAM350_Slim -Token ghp_xxx

param(
    [string]$RepoName = "CAM350_Slim",
    [string]$Token = ""
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
Set-Location $root

function Find-Gh {
    foreach ($p in @("C:\Program Files\GitHub CLI\gh.exe", "$env:LOCALAPPDATA\GitHubCLI\bin\gh.exe")) {
        if (Test-Path $p) { return $p }
    }
    $c = Get-Command gh -ErrorAction SilentlyContinue
    if ($c) { return $c.Source }
    throw "找不到 gh，请先执行： winget install --id GitHub.cli -e"
}
$gh = Find-Gh

# ---------- 1) 登录 ----------
& $gh auth status 2>$null | Out-Null
$loggedIn = ($LASTEXITCODE -eq 0)
if (-not $loggedIn) {
    if (-not $Token) {
        Write-Host "需要 GitHub Personal Access Token（勾 repo 权限）" -ForegroundColor Yellow
        Write-Host "  生成地址: https://github.com/settings/tokens/new?scopes=repo&description=CAM350-Slim"
        $sec = Read-Host "粘贴 token" -AsSecureString
        $Token = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
    }
    $Token = $Token.Trim()
    if ($Token.Length -lt 20) { throw "token 长度不对" }
    $tmp = Join-Path $env:TEMP "gh_token.txt"
    Set-Content -LiteralPath $tmp -Value $Token -Encoding ASCII -NoNewline
    try {
        Get-Content -LiteralPath $tmp -Raw | & $gh auth login --hostname github.com --git-protocol https --with-token
        if ($LASTEXITCODE -ne 0) { throw "登录失败：token 无效或缺少 repo 权限" }
    } finally { Remove-Item $tmp -Force -ErrorAction SilentlyContinue }
}
& $gh auth setup-git
$owner = (& $gh api user --jq .login).Trim()
Write-Host "已登录: $owner" -ForegroundColor Green

# ---------- 2) 定位仓库 ----------
$repo = "$owner/$RepoName"
& $gh repo view $repo 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "仓库 $repo 不存在，尝试按名称匹配已有仓库..." -ForegroundColor Yellow
    $cands = (& $gh repo list $owner --limit 100 --json name --jq '.[].name') | Where-Object { $_ -match 'cam350' }
    if ($cands) {
        $RepoName = @($cands)[0]
        $repo = "$owner/$RepoName"
        Write-Host "使用已有仓库: $repo" -ForegroundColor Green
    } else {
        Write-Host "创建新仓库: $repo" -ForegroundColor Yellow
        & $gh repo create $repo --public --description "CAM350 15.1 Slim (2D only, in-binary network cut)"
        if ($LASTEXITCODE -ne 0) { throw "创建仓库失败（可能是同名已存在但为私有，或权限不足）" }
    }
}

# ---------- 3) 推送 ----------
$hasOrigin = (& git remote) -contains "origin"
if ($hasOrigin) { & git remote set-url origin "https://github.com/$repo.git" }
else { & git remote add origin "https://github.com/$repo.git" }
& git add -A
if ((& git status --porcelain)) { & git commit -m "chore: update" | Out-Null }
& git branch -M main
Write-Host "推送代码..." -ForegroundColor Cyan
& git push -u origin main
if ($LASTEXITCODE -ne 0) {
    Write-Host "push 被拒，尝试 rebase 后重推..." -ForegroundColor Yellow
    & git pull --rebase origin main
    & git push -u origin main
    if ($LASTEXITCODE -ne 0) { throw "推送失败，请检查仓库是否为空仓/权限" }
}

# ---------- 4) Release + 附件 ----------
$assets = @()
foreach ($p in @("D:\CAM350_15.1_Slim_Portable.zip", "D:\CAM350_15.1_Slim_Setup.exe")) {
    if (Test-Path $p) { $assets += $p } else { Write-Host "缺少: $p" -ForegroundColor Yellow }
}
if ($assets.Count -eq 0) { throw "没有可上传的产物" }

$tag = "v15.1-slim"
& $gh release view $tag --repo $repo 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Release $tag 已存在，追加/覆盖附件..." -ForegroundColor Yellow
    & $gh release upload $tag @assets --repo $repo --clobber
} else {
    Write-Host "创建 Release $tag 并上传 $($assets.Count) 个附件（约 510 MB，请耐心等）..." -ForegroundColor Cyan
    $notes = Join-Path $root "RELEASE_NOTES.md"
    & $gh release create $tag @assets --repo $repo --title "CAM350 15.1 Slim $tag" --notes-file $notes
}
if ($LASTEXITCODE -ne 0) { throw "Release 创建/上传失败" }

Write-Host ""
Write-Host "全部完成" -ForegroundColor Green
Write-Host ("仓库 : https://github.com/$repo")
& $gh release view $tag --repo $repo --json url --jq .url
