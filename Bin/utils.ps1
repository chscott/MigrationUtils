# Prints to powershell.log
function PrintToLog([string]$logFile, [string]$logLine) {

	$dateTime = $(Get-Date -format G)
	Add-Content ${logFile} "${dateTime} ${logLine}"
	
}

# Checks to make sure PowerShell is at the correct version
function CheckPSVersion() {

	$psVersion = $PSVersionTable.PSVersion.Major
	if (${psVersion} -lt 5) {
		PrintToLog ${psLogFile} "Unsupported PowerShell version. Please upgrade to PowerShell 5 or later."
		PrintToLog ${psLogFile} "Script ${scriptName} exiting with error"
		exit -1
	}
	
}