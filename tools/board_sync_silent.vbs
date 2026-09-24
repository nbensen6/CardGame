' Run board_pull.cmd with no window at all.
'
' The scheduled task and the log-on shortcut both used to launch the .cmd
' directly, which pops a console on Nick's screen every half hour -- the exact
' thing the whole off-screen rule exists to avoid. A batch file cannot hide its
' own console (it already has one by the time it runs), and "minimised" still
' flashes, so the launcher has to be something that never creates one.
'
' WshShell.Run's 0 means hidden, False means do not wait. The desktop
' "Sync the agents" shortcut deliberately still runs the .cmd directly: that
' one is a manual click, and a manual click should show its output.
Option Explicit
Dim sh, here
here = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set sh = CreateObject("WScript.Shell")
sh.Run """" & here & "board_pull.cmd""", 0, False
