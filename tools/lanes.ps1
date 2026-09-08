# Lane control panel — start, pause or kill the local agent lanes.
#
# Double-clicked from a desktop shortcut. Two lanes, three actions each, and a
# live status line so you can tell at a glance whether anything is chewing the
# machine before you start a game.
#
#   Start now   launches run.cmd directly, so it works even while the lane is
#               paused — a one-off run without un-pausing the schedule
#   Pause       disables the scheduled task; an in-flight run is left to finish
#   Resume      re-enables it
#   Kill        stops a run that is in flight right now, leaving the schedule
#               alone
#
# Telling the two lanes' processes apart: they share one claude.exe in
# G:\fixer-bin, so the executable path cannot distinguish them. The COMMAND LINE
# can — each run names its own brief ("tools/builder/BRIEF.md"), which is what
# the matcher below keys on.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ROOT = Split-Path -Parent $PSScriptRoot

$LANES = @(
    @{ Name = 'Builder'; Task = 'TitanSlayers Builder'
       Cmd = Join-Path $ROOT 'tools\builder\run.cmd'; Match = 'tools/builder/BRIEF.md'
       Blurb = 'One system change per run, on a branch' }
    @{ Name = 'Inspector'; Task = 'TitanSlayers Fixer'
       Cmd = Join-Path $ROOT 'tools\fixer\run.cmd'; Match = 'tools/fixer/BRIEF.md'
       Blurb = 'Plays the game and files findings' }
)

function Get-LaneProc($match) {
    Get-CimInstance Win32_Process -Filter "Name='claude.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -and $_.CommandLine -like "*$match*" }
}

function Get-LaneState($lane) {
    $running = [bool](Get-LaneProc $lane.Match)
    $task = Get-ScheduledTask -TaskName $lane.Task -ErrorAction SilentlyContinue
    if (-not $task) { return @{ Text = 'no scheduled task'; Colour = 'Gray'; Running = $running; Paused = $true } }
    $info = Get-ScheduledTaskInfo -TaskName $lane.Task -ErrorAction SilentlyContinue
    $paused = $task.State -eq 'Disabled'
    if ($running) {
        return @{ Text = 'RUNNING now'; Colour = 'DarkOrange'; Running = $true; Paused = $paused }
    }
    if ($paused) { return @{ Text = 'paused'; Colour = 'Firebrick'; Running = $false; Paused = $true } }
    $next = if ($info -and $info.NextRunTime) { $info.NextRunTime.ToString('HH:mm') } else { '?' }
    return @{ Text = "idle, next run $next"; Colour = 'ForestGreen'; Running = $false; Paused = $false }
}

$form = New-Object Windows.Forms.Form
$form.Text = 'Titan-Slayers lanes'
$form.Size = New-Object Drawing.Size(470, 290)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.Font = New-Object Drawing.Font('Segoe UI', 9)

$rows = @()
$y = 14
foreach ($lane in $LANES) {
    $title = New-Object Windows.Forms.Label
    $title.Text = $lane.Name
    $title.Font = New-Object Drawing.Font('Segoe UI', 11, [Drawing.FontStyle]::Bold)
    $title.Location = New-Object Drawing.Point(16, $y)
    $title.Size = New-Object Drawing.Size(150, 22)
    $form.Controls.Add($title)

    $status = New-Object Windows.Forms.Label
    $status.Location = New-Object Drawing.Point(150, ($y + 3))
    $status.Size = New-Object Drawing.Size(290, 20)
    $status.Font = New-Object Drawing.Font('Segoe UI', 9, [Drawing.FontStyle]::Bold)
    $form.Controls.Add($status)

    $blurb = New-Object Windows.Forms.Label
    $blurb.Text = $lane.Blurb
    $blurb.ForeColor = 'DimGray'
    $blurb.Location = New-Object Drawing.Point(16, ($y + 24))
    $blurb.Size = New-Object Drawing.Size(420, 18)
    $form.Controls.Add($blurb)

    $bx = 16
    $buttons = @{}
    foreach ($act in 'Start now', 'Pause', 'Kill') {
        $b = New-Object Windows.Forms.Button
        $b.Text = $act
        $b.Location = New-Object Drawing.Point($bx, ($y + 46))
        $b.Size = New-Object Drawing.Size(96, 28)
        $form.Controls.Add($b)
        $buttons[$act] = $b
        $bx += 104
    }

    $rows += @{ Lane = $lane; Status = $status; Buttons = $buttons }
    $y += 106
}

function Refresh-All {
    foreach ($r in $script:rows) {
        $s = Get-LaneState $r.Lane
        $r.Status.Text = $s.Text
        $r.Status.ForeColor = $s.Colour
        # One button that says what it will DO, rather than two that look the
        # same and only one of which is meaningful.
        $r.Buttons['Pause'].Text = if ($s.Paused) { 'Resume' } else { 'Pause' }
        $r.Buttons['Kill'].Enabled = $s.Running
        $r.Buttons['Start now'].Enabled = -not $s.Running
    }
}

foreach ($r in $rows) {
    $lane = $r.Lane
    $r.Buttons['Start now'].Add_Click({
        Start-Process cmd.exe -ArgumentList '/c', "`"$($lane.Cmd)`"" -WindowStyle Hidden
        Start-Sleep -Milliseconds 900
        Refresh-All
    }.GetNewClosure())
    $r.Buttons['Pause'].Add_Click({
        $t = Get-ScheduledTask -TaskName $lane.Task -ErrorAction SilentlyContinue
        if ($t) {
            if ($t.State -eq 'Disabled') { Enable-ScheduledTask -TaskName $lane.Task | Out-Null }
            else { Disable-ScheduledTask -TaskName $lane.Task | Out-Null }
        }
        Refresh-All
    }.GetNewClosure())
    $r.Buttons['Kill'].Add_Click({
        Get-LaneProc $lane.Match | ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Start-Sleep -Milliseconds 500
        Refresh-All
    }.GetNewClosure())
}

$note = New-Object Windows.Forms.Label
$note.Text = 'Pause stops future runs. Kill stops one already in flight.'
$note.ForeColor = 'DimGray'
$note.Location = New-Object Drawing.Point(16, ($y + 4))
$note.Size = New-Object Drawing.Size(420, 18)
$form.Controls.Add($note)

# Status goes stale while the window sits open — a run can start or finish
# behind it.
$timer = New-Object Windows.Forms.Timer
$timer.Interval = 3000
$timer.Add_Tick({ Refresh-All })
$timer.Start()

Refresh-All
$form.Topmost = $true
[void]$form.ShowDialog()
$timer.Stop()
