# 代码版本管理（中文小工具）
# 双击「打开代码管理.cmd」启动
# 功能：① 一键上传改动到 GitHub  ② 一键回到选中的历史版本

param([switch]$Test)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$Root = "E:\Wheeled-Legged-Robot\NEW CODE"

function Invoke-Git {
    param([string[]]$GitArgs)
    $out = & git -C $Root @GitArgs 2>&1
    return [pscustomobject]@{ Code = $LASTEXITCODE; Text = (($out | Out-String).Trim()) }
}

# ---------------- 界面 ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "代码版本管理 —— 轮腿机器人"
$form.Size = New-Object System.Drawing.Size(900, 640)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(246, 248, 250)

$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Location = New-Object System.Drawing.Point(14, 12)
$lblStatus.Size = New-Object System.Drawing.Size(860, 34)
$lblStatus.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 10, [System.Drawing.FontStyle]::Bold)
$lblStatus.Text = "读取中…"
$form.Controls.Add($lblStatus)

$gbChanges = New-Object System.Windows.Forms.GroupBox
$gbChanges.Text = "① 还没上传的改动"
$gbChanges.Location = New-Object System.Drawing.Point(14, 52)
$gbChanges.Size = New-Object System.Drawing.Size(430, 245)
$form.Controls.Add($gbChanges)

$lvChanges = New-Object System.Windows.Forms.ListView
$lvChanges.Location = New-Object System.Drawing.Point(10, 24)
$lvChanges.Size = New-Object System.Drawing.Size(410, 210)
$lvChanges.View = "Details"
$lvChanges.FullRowSelect = $true
$lvChanges.GridLines = $true
[void]$lvChanges.Columns.Add("文件", 290)
[void]$lvChanges.Columns.Add("状态", 100)
$gbChanges.Controls.Add($lvChanges)

$gbHistory = New-Object System.Windows.Forms.GroupBox
$gbHistory.Text = "② 历史版本（双击某一行，可回到那一版）"
$gbHistory.Location = New-Object System.Drawing.Point(14, 307)
$gbHistory.Size = New-Object System.Drawing.Size(430, 285)
$form.Controls.Add($gbHistory)

$lvHistory = New-Object System.Windows.Forms.ListView
$lvHistory.Location = New-Object System.Drawing.Point(10, 24)
$lvHistory.Size = New-Object System.Drawing.Size(410, 250)
$lvHistory.View = "Details"
$lvHistory.FullRowSelect = $true
$lvHistory.GridLines = $true
[void]$lvHistory.Columns.Add("时间", 120)
[void]$lvHistory.Columns.Add("说明", 260)
$gbHistory.Controls.Add($lvHistory)

$lblMsg = New-Object System.Windows.Forms.Label
$lblMsg.Location = New-Object System.Drawing.Point(460, 60)
$lblMsg.Size = New-Object System.Drawing.Size(410, 22)
$lblMsg.Text = "这次改了什么？（一句话，随便写）"
$form.Controls.Add($lblMsg)

$txtMessage = New-Object System.Windows.Forms.TextBox
$txtMessage.Location = New-Object System.Drawing.Point(460, 86)
$txtMessage.Size = New-Object System.Drawing.Size(410, 26)
$txtMessage.Text = ""
$form.Controls.Add($txtMessage)

$btnUpload = New-Object System.Windows.Forms.Button
$btnUpload.Location = New-Object System.Drawing.Point(460, 130)
$btnUpload.Size = New-Object System.Drawing.Size(410, 54)
$btnUpload.Text = "⬆  上传改动到 GitHub"
$btnUpload.BackColor = [System.Drawing.Color]::FromArgb(35, 134, 54)
$btnUpload.ForeColor = [System.Drawing.Color]::White
$btnUpload.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnUpload.FlatStyle = "Flat"
$form.Controls.Add($btnUpload)

$btnRollback = New-Object System.Windows.Forms.Button
$btnRollback.Location = New-Object System.Drawing.Point(460, 196)
$btnRollback.Size = New-Object System.Drawing.Size(410, 54)
$btnRollback.Text = "↩  回到选中的历史版本"
$btnRollback.BackColor = [System.Drawing.Color]::FromArgb(207, 98, 40)
$btnRollback.ForeColor = [System.Drawing.Color]::White
$btnRollback.Font = New-Object System.Drawing.Font("Microsoft YaHei UI", 11, [System.Drawing.FontStyle]::Bold)
$btnRollback.FlatStyle = "Flat"
$form.Controls.Add($btnRollback)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Location = New-Object System.Drawing.Point(460, 262)
$btnRefresh.Size = New-Object System.Drawing.Size(200, 36)
$btnRefresh.Text = "刷新"
$form.Controls.Add($btnRefresh)

$btnOpenFolder = New-Object System.Windows.Forms.Button
$btnOpenFolder.Location = New-Object System.Drawing.Point(670, 262)
$btnOpenFolder.Size = New-Object System.Drawing.Size(200, 36)
$btnOpenFolder.Text = "打开代码文件夹"
$form.Controls.Add($btnOpenFolder)

$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Location = New-Object System.Drawing.Point(460, 312)
$txtLog.Size = New-Object System.Drawing.Size(410, 278)
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.BackColor = [System.Drawing.Color]::White
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtLog)

# ---------------- 逻辑 ----------------
function Write-Log([string]$text) {
    $txtLog.AppendText(("[{0}] {1}`r`n" -f (Get-Date -Format "HH:mm:ss"), $text))
    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

function Commit-WithMessage([string]$message) {
    # 中文说明写成 UTF-8 文件再提交，避免控制台编码把中文变成乱码
    $tmp = Join-Path $env:TEMP ("commitmsg_" + [guid]::NewGuid().ToString("N") + ".txt")
    [System.IO.File]::WriteAllText($tmp, $message, (New-Object System.Text.UTF8Encoding $false))
    try {
        return Invoke-Git @("commit", "-F", $tmp)
    }
    finally {
        Remove-Item -LiteralPath $tmp -ErrorAction SilentlyContinue
    }
}

function Update-All {
    $txtLog.Clear()
    $lvChanges.Items.Clear()
    $lvHistory.Items.Clear()

    $branch = (Invoke-Git @("rev-parse", "--abbrev-ref", "HEAD")).Text
    $ahead = 0
    $cnt = (Invoke-Git @("rev-list", "--count", "@{u}..HEAD")).Text
    [void][int]::TryParse(($cnt -split "`n")[0].Trim(), [ref]$ahead)

    $dirty = ((Invoke-Git @("status", "--porcelain")).Text).Length -gt 0
    $sync = if ($ahead -gt 0) { "有 $ahead 个提交没传上去" } else { "已和 GitHub 一致" }
    $lblStatus.Text = ("当前分支：{0}    状态：{1}" -f $branch, $sync)
    if ($ahead -gt 0) { $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(207, 98, 40) }
    else { $lblStatus.ForeColor = [System.Drawing.Color]::FromArgb(35, 134, 54) }

    $status = (Invoke-Git @("status", "--porcelain")).Text
    if ([string]::IsNullOrWhiteSpace($status)) {
        $i = $lvChanges.Items.Add("（没有未上传的改动）")
        [void]$i.SubItems.Add("")
    }
    else {
        foreach ($line in ($status -split "`n")) {
            if ($line.Trim().Length -lt 3) { continue }
            $code = $line.Substring(0, 2).Trim()
            $path = $line.Substring(3).Trim().Trim('"')
            $desc = switch -Wildcard ($code) {
                "??" { "新文件" }
                "M" { "修改" }
                "A" { "新增" }
                "D" { "删除" }
                "R" { "改名" }
                default { $code }
            }
            $i = $lvChanges.Items.Add($path)
            [void]$i.SubItems.Add($desc)
        }
    }

    $log = (Invoke-Git @("log", "-40", "--date=format:%m-%d %H:%M", "--format=%ad|%s|%H")).Text
    foreach ($line in ($log -split "`n")) {
        if ($line.Trim().Length -eq 0) { continue }
        $parts = $line.Split("|")
        if ($parts.Count -lt 3) { continue }
        $i = $lvHistory.Items.Add($parts[0])
        [void]$i.SubItems.Add($parts[1])
        $i.Tag = $parts[2]
    }
    Write-Log ("已刷新，历史版本 {0} 条" -f $lvHistory.Items.Count)
}

$btnRefresh.Add_Click({ Update-All })

$btnOpenFolder.Add_Click({
    Start-Process explorer.exe -ArgumentList "`"$Root`""
})

$btnUpload.Add_Click({
    $btnUpload.Enabled = $false
    try {
        $msg = $txtMessage.Text.Trim()
        if ([string]::IsNullOrWhiteSpace($msg)) { $msg = "修改 " + (Get-Date -Format "MM-dd HH:mm") }

        Write-Log "正在检查改动…"
        $st = (Invoke-Git @("status", "--porcelain")).Text
        if ([string]::IsNullOrWhiteSpace($st)) {
            Write-Log "没有新改动，无需上传。"
            [void][System.Windows.Forms.MessageBox]::Show("没有检测到新改动。", "提示")
            return
        }

        Write-Log "正在提交：$msg"
        [void](Invoke-Git @("add", "-A"))
        $c = Commit-WithMessage $msg
        if ($c.Code -ne 0) {
            Write-Log ("提交失败：" + $c.Text)
            [void][System.Windows.Forms.MessageBox]::Show("提交失败：`n" + $c.Text, "出错了")
            return
        }
        Write-Log "提交成功，正在上传到 GitHub…"
        $p = Invoke-Git @("push")
        if ($p.Code -eq 0) {
            Write-Log "上传成功 ✅"
            $txtMessage.Text = ""
        }
        else {
            Write-Log ("上传失败（可能是网络），提交已保存在本地：" + $p.Text)
            [void][System.Windows.Forms.MessageBox]::Show("上传失败，多半是网络问题。`n改动已经保存在本地，联网后再点一次上传即可。`n`n" + $p.Text, "提示")
        }
    }
    finally {
        $btnUpload.Enabled = $true
        Update-All
    }
})

$btnRollback.Add_Click({
    if ($lvHistory.SelectedItems.Count -eq 0) {
        [void][System.Windows.Forms.MessageBox]::Show("请先在下面的历史列表里，点一下你想回到的那一行。", "提示")
        return
    }
    $item = $lvHistory.SelectedItems[0]
    $sha = $item.Tag
    $when = $item.SubItems[0].Text
    $what = $item.SubItems[1].Text

    $ans = [System.Windows.Forms.MessageBox]::Show(
        ("确定把代码退回这一版吗？`n`n时间：{0}`n说明：{1}`n`n现在没上传的改动会丢掉。历史记录不会丢，之后还能再回来。" -f $when, $what),
        "确认回退", "YesNo", "Warning")
    if ($ans -ne "Yes") { return }

    $btnRollback.Enabled = $false
    try {
        Write-Log "正在回退到 $sha …"
        $r = Invoke-Git @("checkout", $sha, "--", ".")
        if ($r.Code -ne 0) {
            Write-Log ("回退失败：" + $r.Text)
            [void][System.Windows.Forms.MessageBox]::Show("回退失败：`n" + $r.Text, "出错了")
            return
        }
        Write-Log "文件已替换成那一版，正在提交…"
        $c = Commit-WithMessage ("回退到 {0}（{1}）" -f $when, $what)
        if ($c.Code -eq 0) {
            Write-Log "正在上传…"
            $p = Invoke-Git @("push")
            if ($p.Code -eq 0) { Write-Log "回退完成，已同步到 GitHub ✅" }
            else { Write-Log ("上传失败，回退已保存在本地：" + $p.Text) }
        }
        else {
            Write-Log "该版本和当前内容相同，无需提交。"
        }
    }
    finally {
        $btnRollback.Enabled = $true
        Update-All
    }
})

$lvHistory.Add_DoubleClick({
    if ($lvHistory.SelectedItems.Count -gt 0) { $btnRollback.PerformClick() }
})

if ($Test) {
    Update-All
    Write-Output "界面构建成功"
    Write-Output ("改动 {0} 行，历史 {1} 条" -f $lvChanges.Items.Count, $lvHistory.Items.Count)
    Write-Output $lblStatus.Text
    $form.Dispose()
    exit 0
}

Update-All
[void]$form.ShowDialog()