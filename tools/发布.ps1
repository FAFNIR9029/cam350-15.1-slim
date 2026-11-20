# 发布到 GitHub：创建仓库（如不存在）-> 推送代码 -> 建 Release 并上传 255 MB 附件
# 用法：
#   1) 先登录： gh auth login
#   2) 运行：  .\tools\发布.ps1 -RepoOwner FAFNIR9029 -RepoName CAM350_Slim

param(
    [string]$RepoOwner = "",
    [string]$RepoName  = "CAM350_Slim",
    [string]$Tag       = "v15.1-slim",
    [switch]$Private
)

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root

function Need-Gh {
    $gh = Get-Command gh -ErrorAction SilentlyContinue
    if (-not $gh) { throw "未找到 gh（GitHub CLI）。请先安装：winget install --id GitHub.cli -e" }
    & gh auth status 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "gh 未登录。请先执行： gh auth login" }
    return $gh.Source
}

$gh = Need-Gh
if (-not $RepoOwner) {
    $RepoOwner = (& gh api user --jq .login).Trim()
}
Write-Host "仓库: $RepoOwner/$RepoName"

# 1) 仓库不存在则创建
$exists = $true
& gh repo view "$RepoOwner/$RepoName" 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { $exists = $false }
if (-not $exists) {
    $vis = if ($Private) { "--private" } else { "--public" }
    Write-Host "创建仓库..."
    & gh repo create "$RepoOwner/$RepoName" $vis --description "CAM350 15.1 Slim（仅 2D · 程序内断网 · 绿色便携）" | Out-Null
}

# 2) 远端与推送
$remote = (& git remote 2>$null)
if ($remote -notcontains "origin") {
    & git remote add origin "https://github.com/$RepoOwner/$RepoName.git"
} else {
    & git remote set-url origin "https://github.com/$RepoOwner/$RepoName.git"
}
& git add -A
$dirty = (& git status --porcelain)
if ($dirty) { & git commit -m "chore: update docs" | Out-Null }
& git branch -M main
& git push -u origin main

# 3) Release + 附件（GitHub 单文件上限 2 GB，255 MB 没问题；不要塞进 git 历史）
$assets = @()
foreach ($p in @("D:\CAM350_15.1_Slim_Portable.zip", "D:\CAM350_15.1_Slim_Setup.exe")) {
    if (Test-Path $p) { $assets += $p }
}
if ($assets.Count -eq 0) { throw "找不到待上传的 zip/exe，请检查路径" }

$notes = Join-Path $root "RELEASE_NOTES.md"
Write-Host "创建 Release $Tag 并上传 $($assets.Count) 个附件（约 510 MB，耗时取决于上行带宽）..."
& gh release create $Tag @assets --title "CAM350 15.1 Slim $Tag" --notes-file $notes

Write-Host ""
Write-Host "完成。Release 页面："
& gh release view $Tag --json url --jq .url
