# Print the path of the newest installed Claude Code binary, or nothing.
#
# A FILE rather than a -Command one-liner inside run.cmd, because cmd's caret
# escaping and PowerShell's pipes do not get along: `^|` inside a backquoted
# `for /f ... usebackq` reached PowerShell as a literal caret and it refused the
# whole expression. Escaping is not worth debugging twice.
#
# Why this needs a real version sort at all: the fixer runs its OWN copy of
# claude.exe rather than the desktop app's, so it never holds the app's binary
# open while the app tries to update it. Picking WHICH version to copy is then
# the only interesting question, and the two obvious answers are both wrong.
#
#   by NAME   a string sort puts 2.1.99 above 2.1.100
#   by DATE   the version folders carry the timestamp of whenever the parent
#             was last touched, so 2.1.247 and 2.1.255 were stamped the same
#             minute on this machine and a dry run picked the older one
#
# Casting to [version] is the only one of the three actually comparing versions.

$root = Join-Path $env:APPDATA 'Claude\claude-code'
if (-not (Test-Path -LiteralPath $root)) { exit 1 }

$dirs = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d+(\.\d+)+$' -and
                   (Test-Path -LiteralPath (Join-Path $_.FullName 'claude.exe')) }
if (-not $dirs) { exit 1 }

$newest = $dirs | Sort-Object { [version]$_.Name } | Select-Object -Last 1
Write-Output $newest.Name
exit 0
