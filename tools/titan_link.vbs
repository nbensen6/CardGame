' The titan: link handler. Windows will not accept a .cmd as a URL protocol
' handler -- it answers "Get an app to open this 'titan' link" and offers the
' Store -- so the registered handler is wscript.exe running this, which is a
' real executable, and this hands the id to tools\play.cmd.
'
' It also runs play.cmd hidden, so clicking a link in Obsidian does not flash a
' console window on the way to the game.
Option Explicit
Dim url, id, sh, here
here = Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\"))
url = ""
If WScript.Arguments.Count > 0 Then url = WScript.Arguments(0)

id = url
If InStr(id, "titan://") = 1 Then id = Mid(id, 9)
id = Replace(id, "/", "")

Set sh = CreateObject("WScript.Shell")
If id = "__check" Or Left(id, 7) = "__echo:" Then
	' Proves the whole chain -- Obsidian -> Windows -> here -- without opening
	' the game. Claude uses this to verify the registration.
	Dim fso, f
	Set fso = CreateObject("Scripting.FileSystemObject")
	Set f = fso.CreateTextFile(sh.ExpandEnvironmentStrings("%TEMP%") & "\titan_link_check.txt", True)
	If Left(id, 7) = "__echo:" Then
		f.WriteLine """" & here & "play.cmd"" " & Mid(id, 8)
	Else
		f.WriteLine "titan link reached the handler at " & Now
	End If
	f.Close
Else
	sh.Run """" & here & "play.cmd"" " & id, 0, False
End If
