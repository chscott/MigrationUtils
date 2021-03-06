#==============================================================================================================================
# Variables

# These variables/values are common to all TMD template scripts
$scriptName 		= split-path -Leaf $MyInvocation.MyCommand.Definition
$scriptPath 		= split-path -parent $MyInvocation.MyCommand.Definition
$parentPath 		= split-path -parent $scriptPath
$tmDataDir 			= "$Env:ProgramData\Transend"
$tmBinDir 			= "${tmDataDir}\Bin"
$tmConfigDir 		= "${tmDataDir}\Configurations"
$tmLogsDir			= "${tmDataDir}\Logs"
$psLogFile			= "${tmLogsDir}\powershell.log"	
$tmTemplateDir 		= "${tmDataDir}\Templates"

# These variables/values change based on the TMD template script. Make sure to update PrintVariables accordingly
$notesAdminId 		= $args[0]
$notesAdminPwd 		= $args[1]
$serviceAccount		= $args[2]
$keyFile			= $args[3]
$tmdPrefix			= "google_api"
$tmdTemplate		= "${tmdPrefix}.tmd"
#==============================================================================================================================


#==============================================================================================================================
# Functions

# Prints the script variables
function PrintVariables() {

	PrintToLog ${psLogFile} "Dumping script variables:"
	PrintToLog ${psLogFile} "   scriptName: ${scriptName}"
	PrintToLog ${psLogFile} "   scriptPath: ${scriptPath}"
	PrintToLog ${psLogFile} "   parentPath: ${parentPath}"
	PrintToLog ${psLogFile} "   tmDataDir: ${tmDataDir}"
	PrintToLog ${psLogFile} "   tmBinDir: ${tmBinDir}"
	PrintToLog ${psLogFile} "   tmConfigDir: ${tmConfigDir}"
	PrintToLog ${psLogFile} "   tmLogsDir: ${tmLogsDir}"
	PrintToLog ${psLogFile} "   psLogFile: ${psLogFile}"
	PrintToLog ${psLogFile} "   tmTemplateDir: ${tmTemplateDir}"
	PrintToLog ${psLogFile} "   notesAdminId: ${notesAdminId}"
	PrintToLog ${psLogFile} "   notesAdminPwd: ********"
	PrintToLog ${psLogFile} "   serviceAccount: ${serviceAccount}"
	PrintToLog ${psLogFile} "   keyFile: ${keyFile}"
	PrintToLog ${psLogFile} "   tmdPrefix: ${tmdPrefix}"
	PrintToLog ${psLogFile} "   tmdTemplate: ${tmdTemplate}"
	
}

# Validates that the variables required to generate a TMD are set
function ValidateTMDVariables() {
	
	if ( !${notesAdminId} -Or !${notesAdminPwd} -Or !${serviceAccount} -Or !${keyfile} ) {
		PrintToLog ${psLogFile} "One or more required parameters are missing"
		PrintToLog ${psLogFile} "Script ${scriptName} exiting with error"
		exit -2
	}
	
}

# Reads in the template, updates the placeholder variables and writes out a new configuration file
function GenerateTMD() {

	(Get-Content ${tmTemplateDir}\${tmdTemplate}) | ` 
	Foreach-Object { `
		$line = $_; `
		if ($line.contains('$TMDATADIR')) { `
			$line.replace('$TMDATADIR',"${tmDataDir}") `
		} elseif ($line.equals('$NOTESADMINPWD;$NOTESADMINID')) { `
			$line.replace('$NOTESADMINPWD;$NOTESADMINID',"${notesAdminPwd};${notesAdminId}") `
		} elseif ($line.contains('$SERVICEACCOUNT|$KEYFILE')) { `
			$line.replace('$SERVICEACCOUNT|$KEYFILE',"${serviceAccount}|${keyFile}") `
		} else { `
			$line `
		} `
	} | `
	Set-Content ${tmConfigDir}\${tmdPrefix}_${dateTime}.tmd
	
}
#==============================================================================================================================


#==============================================================================================================================
# Main

# Source the utils script
. ${tmBinDir}\utils.ps1

PrintToLog ${psLogFile} "Script ${scriptName} starting"

# Make sure PowerShell is at the minimum required level
CheckPSVersion

# Dump the script variables to the log for debugging
PrintVariables

# Get the datetime string
$dateTime = $(Get-Date -format yyyyMMdd_HHmmss)

# Validate that the necessary TMD variables are set
ValidateTMDVariables

# Generate the TMD
GenerateTMD

# Check to see if the TMD was created
if (Test-Path ${tmConfigDir}\${tmdPrefix}_${dateTime}.tmd) {
	PrintToLog ${psLogFile} "Generated Transend configuration file ${tmConfigDir}\${tmdPrefix}_${dateTime}.tmd"
} 
else {
	PrintToLog ${psLogFile} "Unable to create Transend configuration file. See ${psLogFile} for details."
}

PrintToLog ${psLogFile} "Script ${scriptName} completed"
#==============================================================================================================================