<#
  回退到历史版本（命令行版）
  ---------------------------
  列出最近的提交，输入编号即可把仓库恢复到那一版，并推送到 GitHub。
  历史不会丢：回退本身也会生成一条新提交。
#>
$ErrorActionPreference = "Continue"
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$RepoRoot = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $RepoRoot ".git"))) { $RepoRoot = $PSScriptRoot }
Set-Location $RepoRoot

function Say($m, $c = "Gray") { Write-Host $m -ForegroundColor $c }

# 未提交改动提醒
$dirty = & git status --porcelain
if ($dirty) {
    Say "注意：仓库里有未提交的改动，回退会覆盖它们。" "Yellow"
    Say ($dirty | Select-Object -First 5 | Out-String).Trim() "DarkGray"
    $ok = Read-Host "继续？(y/N)"
    if ($ok -ne "y" -and $ok -ne "Y") { Say "已取消。"; exit 0 }
}

Say ""
Say "  最近 30 个版本（● = 改过 src/ 代码的版本）" "Cyan"
Say "  ------------------------------------------------" "DarkGray"

$codeShas = @{}
(& git log -60 --format="%h" -- src 2>$null) | ForEach-Object { if ($_) { $codeShas[$_.Trim()] = $true } }
$lines = & git log -30 --date=format:'%m-%d %H:%M' --format='%h%x09%ad%x09%s'
$i = 0
$commits = @()
foreach ($ln in $lines) {
    if ([string]::IsNullOrWhiteSpace($ln)) { continue }
    $p = $ln -split "`t"
    if ($p.Count -lt 3) { continue }
    $i++
    $commits += [pscustomobject]@{ No = $i; Sha = $p[0]; Time = $p[1]; Subject = $p[2] }
    $mark = if ($codeShas.ContainsKey($p[0])) { "●" } else { " " }
    Write-Host ("  {0,2}) {1} {2}  {3}" -f $i, $mark, $p[1], $p[2])
}

Say "  ------------------------------------------------" "DarkGray"
Say "  q) 退出" "DarkGray"
Say ""

$sel = Read-Host "  输入要回到的版本编号"
if ($sel -eq "q" -or $sel -eq "Q" -or [string]::IsNullOrWhiteSpace($sel)) { Say "已取消。"; exit 0 }
if ($sel -notmatch '^\d+$' -or [int]$sel -lt 1 -or [int]$sel -gt $commits.Count) {
    Say "编号无效。" "Red"; exit 1
}

$c = $commits[[int]$sel - 1]
Say ""
Say ("  即将把代码恢复到：{0}  {1}" -f $c.Time, $c.Subject) "White"
$ok = Read-Host "  确认？(y/N)"
if ($ok -ne "y" -and $ok -ne "Y") { Say "已取消。"; exit 0 }

Say ""
Say "  正在恢复文件 ……" "Cyan"
& git checkout $c.Sha -- . 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Say "  恢复失败。" "Red"; pause; exit 1 }

$st = & git status --porcelain
if (-not $st) {
    Say "  当前代码已经和那一版一致，无需回退。" "Green"; pause; exit 0
}

$msg = "回退到 $($c.Sha)（$($c.Subject)）"
$mf = Join-Path $env:TEMP ("rbmsg_" + [guid]::NewGuid().ToString("N") + ".txt")
[System.IO.File]::WriteAllText($mf, $msg, (New-Object System.Text.UTF8Encoding $false))
& git commit -q -F $mf
Remove-Item $mf -Force -ErrorAction SilentlyContinue
if ($LASTEXITCODE -ne 0) { Say "  提交失败。" "Red"; pause; exit 1 }
Say ("  已提交：{0}" -f $msg) "Green"

Say "  正在推送到 GitHub ……" "Cyan"
& git push -q 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Say "  回退完成，已同步到 GitHub ✅" "Green"
    Say ("  https://github.com/Why-Yhy/Wheeled-Legged-Robot/commit/" + (& git rev-parse --short HEAD)) "Cyan"
}
else {
    Say "  推送失败（网络问题），回退已保存在本地，稍后再跑一次或手动 git push。" "Yellow"
}
Say ""
pause