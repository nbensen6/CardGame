' Start the link helper with no window.
'
' Same reason as board_sync_silent.vbs: a console appearing on Nick's screen is
' the one thing this project is not allowed to do. board_link.py exits quietly
' when the port is already bound, so running this again is harmless -- which is
' what makes it safe for the half-hourly sync to use as a keep-alive.
Option Explicit
Dim sh, here
here = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
Set sh = CreateObject("WScript.Shell")
sh.Run "pythonw """ & here & "board_link.py""", 0, False
