<#
  auto-sync.ps1 —— 本地改代码，自动 commit + push 到 GitHub
  ---------------------------------------------------------
  用法：
    1. 把这个文件复制到你的项目根目录（已经 git init 并关联好远程仓库的目录）
    2. 右键「使用 PowerShell 运行」，或者在这个目录打开终端执行：
         powershell -NoProfile -ExecutionPolicy Bypass -File .\auto-sync.ps1
    3. 停止：窗口里按 Ctrl+C

  原理：每 N 秒看一次 git status。文件改动后「安静」一个周期才提交，
        所以打字打一半不会被提交成一条垃圾记录；提交完立即 push。
        断网时 commit 留在本地，恢复后会自动补推（不会丢版本）。

  参数：
    -IntervalSec   检查间隔秒数，默认 5
    -MessagePrefix 自动提交的说明前缀，默认 "auto: "
    -MaxFiles      单次允许自动提交的最大文件数，默认 500（防呆：忘了 .gitignore）
#>
param(
    [int]$IntervalSec  = 5,
    [string]$MessagePrefix = "auto: ",
    [int]$MaxFiles     = 500
)

$ErrorActionPreference = "Continue"
Set-Location -LiteralPath $PSScriptRoot

function Log([string]$msg, [string]$color = "Gray") {
    Write-Host ("[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $msg) -ForegroundColor $color
}

# ---------- 前置检查 ----------
if (-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot ".git"))) {
    Log "这个目录不是 git 仓库：$PSScriptRoot" "Red"
    Log "请先 git init 并 git remote add origin <仓库地址>，再运行本脚本。" "Yellow"
    Read-Host "按回车退出"
    exit 1
}

$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
$branch = "$branch".Trim()
$upstream = "$(git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>$null)".Trim()
if ([string]::IsNullOrWhiteSpace($upstream) -or $upstream -match "fatal|no upstream") {
    Log "当前分支 [$branch] 还没有关联远程分支，先执行一次：" "Red"
    Log "    git push -u origin $branch" "Yellow"
    Read-Host "按回车退出"
    exit 1
}

Log ("开始监听：{0}" -f $PSScriptRoot) "Cyan"
Log ("分支 {0} -> {1}，每 {2} 秒检查一次。按 Ctrl+C 停止。" -f $branch, $upstream, $IntervalSec) "Cyan"

$prevStatus     = $null
$pushWarned     = $false
$conflictWarned = $false

while ($true) {
    try {
        # 合并/变基冲突时不自动提交，避免把冲突标记写进历史
        $unmerged = git ls-files -u
        if ($unmerged) {
            if (-not $conflictWarned) {
                Log "检测到未解决的冲突，自动提交已暂停。解决冲突后会自动恢复。" "Yellow"
                $conflictWarned = $true
            }
            Start-Sleep -Seconds $IntervalSec
            continue
        }
        $conflictWarned = $false

        $status  = (git status --porcelain) -join "`n"

        if ($status -and $status -eq $prevStatus) {
            # 工作区已经稳定了一个周期 —— 提交
            $changed = (git status --porcelain | Measure-Object).Count
            if ($changed -gt $MaxFiles) {
                Log "待提交文件 $changed 个（超过 $MaxFiles），可能没写 .gitignore，已跳过。" "Red"
                Log "检查一下：git status --short" "Yellow"
                $prevStatus = $null
            }
            else {
                git add -A 2>&1 | Out-Null
                $msg = "$MessagePrefix" + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                git commit -q -m $msg 2>&1 | Out-Null
                if ($LASTEXITCODE -eq 0) {
                    Log "已提交：$msg（$changed 个文件）" "Green"
                }
                $prevStatus = $null
            }
        }
        else {
            $prevStatus = $status
        }

        # 只要本地领先远程就推（这样断网期间的提交恢复后会自动补推）
        $aheadRaw = "$(git rev-list --count '@{u}..HEAD' 2>$null)".Trim()
        $ahead = 0
        [void][int]::TryParse($aheadRaw, [ref]$ahead)

        if ($ahead -gt 0) {
            git push -q 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Log "已推送 $ahead 个提交到 $upstream" "Green"
                $pushWarned = $false
            }
            elseif (-not $pushWarned) {
                Log "推送失败（网络 / 代理 localhost:7897 / 权限）。稍后自动重试。" "Yellow"
                $pushWarned = $true
            }
        }
    }
    catch {
        Log "出错：$($_.Exception.Message)" "Red"
    }

    Start-Sleep -Seconds $IntervalSec
}