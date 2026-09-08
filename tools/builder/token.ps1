# Print the CLI's OAuth token from USER scope, or nothing.
#
# In its own file for the same reason tools/fixer/newest-claude.ps1 is: a
# PowerShell one-liner inlined into a cmd `for /f` block gets mangled. cmd
# counts parentheses naively, and GetEnvironmentVariable('NAME','User') is full
# of them even inside quotes -- the inline version emitted "operable program or
# batch file" and left every SET after it unassigned, which showed up as an
# empty claude.exe path rather than as a parse error.
#
# USER scope lives in the registry and only reaches a process started after it
# was set, so a scheduled task or a long-lived shell has never heard of it. That
# absence is reported by the CLI as "OAuth session expired and could not be
# refreshed", which names the wrong cause and has cost this project days.
$t = [Environment]::GetEnvironmentVariable('CLAUDE_CODE_OAUTH_TOKEN', 'User')
if ($t) { Write-Output $t }
