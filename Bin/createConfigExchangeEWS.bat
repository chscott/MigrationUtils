@echo off

REM Set variables based on script arguments
set legacyServer=%1
set notesAdminId=%2
set notesAdminPwd=%3
set exchangeImpId=%4
set exchangeImpPwd=%5

REM Call the PowerShell script that does the real work
powershell -File "%~dpn0.ps1" %legacyServer% %notesAdminId% %notesAdminPwd% %exchangeImpId% %exchangeImpPwd%

REM Report the last error level
echo Exit code is %errorlevel%