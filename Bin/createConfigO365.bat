@echo off

REM Set variables based on script arguments
set notesAdminId=%1
set notesAdminPwd=%2
set exchangeImpId=%3
set exchangeImpPwd=%4

REM Call the PowerShell script that does the real work
powershell -File "%~dpn0.ps1" %notesAdminId% %notesAdminPwd% %exchangeImpId% %exchangeImpPwd%

REM Report the last error level
echo Exit code is %errorlevel%