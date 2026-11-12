<#
  同步代码并上传
  ----------------
  把你外部工作目录（默认 E:\Wheeled-Legged-Robot\Code\Changes）里改动的源码，
  同步到仓库的 src/ 下，然后自动提交并推送到 GitHub。

  只同步源码和工程文件，编译产物（.o/.d/.crf/.axf/.map/.uvguix 等）一律跳过。
  用法：双击「同步代码.cmd」，或 powershell -File tools\sync-code.ps1
  预览不提交：加 -DryRun
#>
param(
    [string]$Source = "E:\Wheeled-Legged-Robot\Code\Changes",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# 仓库根目录 = 本脚本所在目录的上一级
$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $RepoRoot ".git"))) { $RepoRoot = $PSScriptRoot }
$Dest = Join-Path $RepoRoot "src"

function Say($msg, $color = "Gray") { Write-Host $msg -ForegroundColor $color }

if (-not (Test-Path $Source)) { Say "找不到工作目录：$Source" "Red"; pause; exit 1 }
if (-not (Test-Path $Dest))   { Say "找不到仓库里的 src 目录：$Dest" "Red"; pause; exit 1 }

Say "工作目录：$Source"
Say "仓库目录：$Dest"
Say ""

# 只同步这些子目录/文件
$tops = @("Core", "User", "Drivers", "Middlewares", "MDK-ARM", ".mxproject", "CtrlBoard-H7_IMU.ioc")

# 排除：编译产物、编辑器/代理目录、生成的工程输出
$skipDir = '\\(\.git|\.agents|\.vscode|Objects|Listings|DebugConfig|RTE)\\.*'
$skipExt = '\.(o|d|crf|axf|elf|hex|bin|map|lst|dep|htm|lnp|sct|iex|bak|uvguix\..*)$'
$skipName = '^(JLinkLog\.txt|JLinkSettings\.ini|\.gitignore)$'
$skipProjectOut = '\\MDK-ARM\\[^\\]+\\'      # MDK 编译输出目录

$files = @()
foreach ($t in $tops) {
    $full = Join-Path $Source $t
    if (-not (Test-Path $full)) { continue }
    if (Test-Path $full -PathType Leaf) { $files += Get-Item $full; continue }
    $files += Get-ChildItem $full -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch $skipDir -and
            $_.FullName -notmatch $skipProjectOut -and
            $_.Name -notmatch $skipExt -and
            $_.Name -notmatch $skipName
        }
}

$changed = @()
foreach ($f in $files) {
    $rel = $f.FullName.Substring($Source.Length + 1)
    $target = Join-Path $Dest $rel
    if (-not (Test-Path $target)) {
        $changed += [pscustomobject]@{ Rel = $rel; Kind = "新增"; Src = $f.FullName }
    }
    elseif ((Get-FileHash $f.FullName).Hash -ne (Get-FileHash $target).Hash) {
        $changed += [pscustomobject]@{ Rel = $rel; Kind = "修改"; Src = $f.FullName }
    }
}

if ($changed.Count -eq 0) {
    Say "没有检测到改动，仓库已经是最新的。" "Green"
    $newest = $files | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($newest) {
        Say ("最近一次源码修改：{0}  {1}" -f $newest.LastWriteTime.ToString("MM-dd HH:mm"),
             $newest.FullName.Substring($Source.Length + 1)) "DarkGray"
    }
    Push-Location $RepoRoot
    $lastCommit = & git log -1 --date=format:'%m-%d %H:%M' --format='%h  %ad  %s' 2>$null
    Pop-Location
    if ($lastCommit) { Say ("最近一次提交：    {0}" -f $lastCommit) "DarkGray" }
    Say "如果刚才改过代码却没被检测到，先确认已在编辑器里保存（Ctrl+S）。" "DarkGray"
    if (-not $DryRun) { pause }
    exit 0
}

Say ("检测到 {0} 个文件有变化：" -f $changed.Count) "Yellow"
$changed | Group-Object Kind | ForEach-Object { Say ("  {0}：{1} 个" -f $_.Name, $_.Count) }
Say ""
$changed | Select-Object -First 25 | ForEach-Object { Say ("  [{0}] {1}" -f $_.Kind, $_.Rel) }
if ($changed.Count -gt 25) { Say ("  …… 其余 {0} 个" -f ($changed.Count - 25)) }

if ($DryRun) { Say ""; Say "（预览模式，未复制、未提交）" "Cyan"; exit 0 }

Say ""
foreach ($c in $changed) {
    $target = Join-Path $Dest $c.Rel
    $dir = Split-Path -Parent $target
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Copy-Item $c.Src $target -Force
}
Say "已复制到仓库 src/" "Green"

Set-Location $RepoRoot
$paths = $changed | ForEach-Object { "src/" + ($_.Rel -replace '\\', '/') }
$paths | ForEach-Object { & git add -- $_ }

$status = & git status --porcelain
if (-not $status) { Say "暂存区没有变化，跳过提交。" "Yellow"; pause; exit 0 }

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$msg = "同步本地代码（$stamp）：$($changed.Count) 个文件"
$mf = Join-Path $env:TEMP ("syncmsg_" + [guid]::NewGuid().ToString("N") + ".txt")
[System.IO.File]::WriteAllText($mf, $msg, (New-Object System.Text.UTF8Encoding $false))
& git commit -q -F $mf
Remove-Item $mf -Force -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) { Say "提交失败" "Red"; pause; exit 1 }
Say "已提交：$msg" "Green"

Say "正在推送到 GitHub ……"
& git push -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Say "上传成功 ✅" "Green"
    Say ("View: https://github.com/Why-Yhy/Wheeled-Legged-Robot/commit/" + (& git rev-parse --short HEAD)) "Cyan"
}
else {
    Say "推送失败（多半是网络/代理），改动已保存在本地，稍后再跑一次即可。" "Yellow"
}
Say ""
pause