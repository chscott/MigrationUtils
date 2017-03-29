# generateLDIF
# Runs ldapsearch to pull an LDIF of users from an LDAP directory. The LDIF can then be used to register the users in Domino.

#==============================================================================================================================
# Variables

# These variables/values are common to all TMD template scripts
$scriptName 			= split-path -Leaf $MyInvocation.MyCommand.Definition
$scriptPath 			= split-path -parent $MyInvocation.MyCommand.Definition
$parentPath 			= split-path -parent $scriptPath
$tmDataDir 				= "$Env:ProgramData\Transend"
$tmBinDir 				= "${tmDataDir}\Bin"
$tmLogsDir				= "${tmDataDir}\Logs"
$psLogFile				= "${tmLogsDir}\powershell.log"	
$notesDir 				= $args[0]
$ldapServer 			= $args[1]
$ldapAdmin 				= $args[2]
$ldapPwd 				= $args[3]
$ldapSearchBase 		= $args[4]
$ldapSearchFilter 		= $args[5]
$ldapSystem				= $args[6]
$ldapSearchExe 			= ${notesDir} + "\ldapsearch.exe"
$ldapAttributes			= ""
$adLdapAttributes 		= "givenName sn initials mail legacyExchangeDN"
$zimbraLdapAttributes 	= "givenName sn initials mail"
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
	PrintToLog ${psLogFile} "   ldapSystem: ${ldapSystem}"
	PrintToLog ${psLogFile} "   ldapSearchExe: ${ldapSearchExe}"
	PrintToLog ${psLogFile} "   ldapAttributes: ${ldapAttributes}"
	PrintToLog ${psLogFile} "   adLdapAttributes: ${adLdapAttributes}"
	PrintToLog ${psLogFile} "   zimbraLdapAttributes: ${zimbraLdapAttributes}"
	
}

# Validate that all required variables are set
function ValidateScriptVariables() {

	if ( !${notesDir} -Or !${ldapServer} -Or !{ldapAdmin} -Or !${ldapPwd} -Or !${ldapSearchBase} -Or !${ldapSearchFilter} -Or !${ldapSystem}) {
		PrintToLog ${psLogFile} "Insufficient arguments"
		exit
	}
	
}

# Set the LDAP attributes to request based on the source LDAP system
function GetLDAPAttributes() {

	if (${ldapSystem}.equals("AD")) {
		$attributes = ${adLdapAttributes}
		PrintToLog ${psLogFile} "Source system is Active Directory. Attributes are: ${attributes}"
	}
	elseif (${ldapSystem}.equals("ZIMBRA")) {
		$attributes = ${zimbraLdapAttributes}
		PrintToLog ${psLogFile} "Source system is Zimbra. Attributes are: ${attributes}"
	}
	else {
		PrintToLog ${psLogFile} "Unsupported source system: ${ldapSystem}"
	}
	
	return ${attributes}
	
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

# Determine the attributes to use
$ldapAttributes = GetLDAPAttributes

# Build the ldapsearch command
$command = "& ""${ldapSearchExe}"" -L -h ""${ldapServer}"" -D ""${ldapAdmin}"" -w ""${ldapPwd}"" -b ""${ldapSearchBase}"" ""${ldapSearchFilter}"" ${ldapAttributes}"

PrintToLog ${psLogFile} "Running command: ${command}"

# Get the raw data back from ldapsearch
$rawData = Invoke-Expression ${command}  | Out-String

# Format the data
${rawData}.replace("`r`n ", "")

PrintToLog ${psLogFile} "Script ${scriptName} completed"