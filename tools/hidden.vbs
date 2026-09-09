' Run a batch file with no console window at all.
'
'   wscript //nologo tools\hidden.vbs "G:\Co Op Game\tools\builder\run.cmd"
'
' Nick, 2026-09-09: "sometimes a cmd pops up and tabs me out of my game for a
' second." That is the lane itself, not the screenshot harness -- the harness
' was fixed separately (screenshot.gd, NO_FOCUS and off-screen). A scheduled
' task whose action is `cmd.exe /c ...` runs in the logged-on session and shows
' a real console window, which takes focus the moment it appears.
'
' Things that do NOT fix it, and why:
'   - Start-Process -WindowStyle Hidden only governs what the LAUNCHER does; the
'     task creates its own process and ignores it.
'   - powershell -WindowStyle Hidden still flashes a host window before the flag
'     applies.
'   - "Run whether user is logged on or not" hides it by moving to session 0 --
'     which has no display, so Godot cannot render and every screenshot the
'     lanes depend on would come back broken. Worse than the problem.
'
' WScript.Shell.Run with intWindowStyle 0 creates the process hidden from the
' start, so there is no window to steal focus even for a frame. bWaitOnReturn
' False so the launcher exits immediately and the task does not sit blocked.
Option Explicit

Dim args, shell, cmd, i
Set args = WScript.Arguments
If args.Count < 1 Then
    WScript.Echo "usage: hidden.vbs <batch file> [args...]"
    WScript.Quit 1
End If

cmd = """" & args(0) & """"
For i = 1 To args.Count - 1
    cmd = cmd & " """ & args(i) & """"
Next

' Run the batch DIRECTLY rather than through `cmd /c`. Wrapping it meant
' building a `cmd /c ""path with spaces" "arg""` string, and cmd's rule for
' stripping the outer pair of quotes is quietly different from every other
' program's -- the first attempt silently launched nothing at all. Run() starts
' a .cmd perfectly well on its own, and style 0 hides the console it creates.
Set shell = CreateObject("WScript.Shell")
shell.Run cmd, 0, False
