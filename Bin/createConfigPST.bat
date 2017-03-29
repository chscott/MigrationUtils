@echo off

REM Set variables based on script arguments
set pstDir=%1
set notesAdminId=%2
set notesAdminPwd=%3

REM Call the PowerShell script that does the real work
powershell -File "%~dpn0.ps1" %pstDir% %notesAdminId% %notesAdminPwd%

REM Report the last error level
echo Exit code is %errorlevel%