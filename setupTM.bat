@echo off

set TMDATADIR=%ProgramData%\Transend

REM Create the necessary directories
if not exist %TMDATADIR% mkdir %TMDATADIR%
if not exist %TMDATADIR%\Attachments mkdir %TMDATADIR%\Attachments
if not exist %TMDATADIR%\Configurations mkdir %TMDATADIR%\Configurations
if not exist %TMDATADIR%\Batches mkdir %TMDATADIR%\Batches
if not exist %TMDATADIR%\Bin mkdir %TMDATADIR%\Bin
if not exist %TMDATADIR%\Dedup mkdir %TMDATADIR%\Dedup
if not exist %TMDATADIR%\Detach mkdir %TMDATADIR%\Detach
if not exist %TMDATADIR%\Exclude mkdir %TMDATADIR%\Exclude
if not exist %TMDATADIR%\Extras mkdir %TMDATADIR%\Extras
if not exist %TMDATADIR%\IDs mkdir %TMDATADIR%\IDs
if not exist %TMDATADIR%\Logs mkdir %TMDATADIR%\Logs
if not exist %TMDATADIR%\Temp mkdir %TMDATADIR%\Temp
if not exist %TMDATADIR%\Templates mkdir %TMDATADIR%\Templates

REM Copy the batch files
copy Bin\* %TMDATADIR%\Bin

REM Copy the extras
copy Extras\* %TMDATADIR%\Extras

REM Copy the templates
copy Templates\* %TMDATADIR%\Templates

REM Add a skipsubs.txt file to the Exclude directory
copy /y nul %TMDATADIR%\Exclude\skipsubs.txt

REM Enable PowerShell script execution
powershell -Command Set-ExecutionPolicy "RemoteSigned" -Scope CurrentUser -Confirm:$false