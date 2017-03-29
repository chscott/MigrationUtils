# getZimbraUsers
# Runs LDAP search against Zimbra target system to retrieve users for registration in Domino

#==============================================================================================================================
# Variables

# These variables/values are common to all TMD template scripts
$scriptName 		= split-path -Leaf $MyInvocation.MyCommand.Definition
$scriptPath 		= split-path -parent $MyInvocation.MyCommand.Definition
$parentPath 		= split-path -parent $scriptPath
$tmDataDir 			= "$Env:ProgramData\Transend"
$tmBinDir 			= "${tmDataDir}\Bin"
$tmLogsDir			= "${tmDataDir}\Logs"
$psLogFile			= "${tmLogsDir}\powershell.log"	
$notesDir 			= $args[0]
$ldapServer 		= $args[1]
$ldapAdmin 			= $args[2]
$ldapPwd 			= $args[3]
$ldapSearchBase 	= $args[4]
$ldapSearchFilter 	= $args[5]
$generateLdifScript	= ${scriptPath} + "\generateLDIF.ps1"
$ldapSystemZimbra	= "ZIMBRA"
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
	PrintToLog ${psLogFile} "   tmLogsDir: ${tmLogsDir}"
	PrintToLog ${psLogFile} "   psLogFile: ${psLogFile}"
	PrintToLog ${psLogFile} "   notesDir: ${notesDir}"
	PrintToLog ${psLogFile} "   ldapServer: ${ldapServer}"
	PrintToLog ${psLogFile} "   ldapAdmin: ${ldapAdmin}"
	PrintToLog ${psLogFile} "   ldapPwd: ${ldapPwd}"
	PrintToLog ${psLogFile} "   ldapSearchBase: ${ldapSearchBase}"
	PrintToLog ${psLogFile} "   ldapSearchFilter: ${ldapSearchFilter}"
	PrintToLog ${psLogFile} "   generateLdifScript: ${generateLdifScript}"
	PrintToLog ${psLogFile} "   ldapSystemZimbra: ${ldapSystemZimbra}"
	
}

# Validate that all required variables are set
function ValidateScriptVariables() {

	If ( !${notesDir} -Or !${ldapServer} -Or !{ldapAdmin} -Or !${ldapPwd} -Or !${ldapSearchBase} -Or !${ldapSearchFilter} ) {
		Write-Host
		Write-Host "Usage: .\${scriptName} <Notes directory> <Zimbra server> <Zimbra admin> <Zimbra admin pwd> <Search base> <Search filter>"
		Write-Host
		Write-Host "Example: .\${scriptName} ""C:\IBM\Notes"" ""ldap.ibm.com"" ""uid=admin,ou=people,dc=ibm,dc=com"" ""password"" ""ou=people,dc=ibm,dc=com"" ""(&(uid=*)(objectClass=inetOrgPerson))"" > C:\ProgramData\Transend\Extras\zimbra.ldif"
		Write-Host
		Write-Host "Enclose all command arguments in quotes, as shown in the example."
		Write-Host
		PrintToLog ${psLogFile} "Insufficient arguments"
		exit
	}
	
}
#==============================================================================================================================


#==============================================================================================================================
# Main

# Source the utils script
. ${tmBinDir}\utils.ps1

PrintToLog ${psLogFile} "Script ${scriptName} starting"

# Dump the script variables to the log for debugging
PrintVariables

# Validate the variables/values
ValidateScriptVariables

# Build the ldapsearch command with the ZIMBRA option
$command = "& ""${generateLdifScript}"" ""${notesDir}"" ""${ldapServer}"" ""${ldapAdmin}"" ""${ldapPwd}"" ""${ldapSearchBase}"" ""${ldapSearchFilter}"" ""${ldapSystemZimbra}"""

PrintToLog ${psLogFile} "Running command: ${command}"

# Run generateLDIF
Invoke-Expression ${command}

PrintToLog ${psLogFile} "Script ${scriptName} completed"