## Overview

MigrationUtils is a set of utilities that help automate manual portions of a mail migration using Transend Migrator. It
contains code to perform some or all of the following tasks, depending on the source mail system:

  - User registration in an on-prem Domino server
  - Generation of batch migration tables
  - Generation of address translation tables
  - Generation of custom Transend Migrator configuration files (TMDs)

In general, a migration project using MigrationUtils is comprised of these steps:

1. Registering new users in the on-prem Domino server. An on-prem Domino server is used as the source system by IBM onboarding
   tools like Mail Onboarding Manager (MOM) that move users and their data to SmartCloud Notes or Verse. This step creates a
   Person document in the Domino Directory and creates a new, empty mail file (NSF) that will be used to hold mail, contacts,
   calendar entries, and tasks from the legacy mail system.

2. Creating batch migration tables. When using Transend Migrator, the most efficient migration strategy is to run a batch
   migration, which migrates multiple users at one time using the same configuration. To do this, Transend Migrator uses
   batch substitution variables in its configuration that are replaced at runtime by actual values corresponding to the users 
   being migrated. MigrationUtils uses information stored in the Person document to generate a batch migration table to prevent
   the migration administrator from needing to generate these manually.

3. Creating address translation tables. During the migration of data, Transend Migrator needs to update names stored in one
   format in the legacy mail system to the format required in Notes and Domino. MigrationUtils uses information in the Person
   document to generate these tables automatically, preventing the migration administrator from needing to generate them
   manually.

4. Performing the data migration using the Transend Migrator client. The Transend Migrator client uses configuration
   information about the source and target environments, batch migration tables, address translation tables, and various
   runtime options to move data from the legacy system to Domino, storing the data in the user's mail file (NSF) on the on-prem
   Domino server. In addition to the batch migration and address translation tables discussed previously, MigrationUtils builds
   a custom Transend Migrator configuration file (TMD) with all of the information needed to connect to the source and target
   environments plus a set of best-practice options.

5. Once users have been migrated from the legacy system to the on-prem Domino server, IBM onboarding tools like Mail Onboarding
   Manager (MOM) are used to migrate the users to SmartCloud Notes/Verse.

The sections that follow will describe in detail how to perform Steps 1-4 above.

## Supported platforms

MigrationUtils supports the following user repositories for registration:

  - Active Directory (via LDAP)
  - Google Directory (via CSV export)
  - Zimbra (via LDAP)
  - Office 365 (via CSV export)

MigrationUtils supports the following systems for data migration:

  - Exchange (EWS and MAPI)
  - PST files
  - Google Apps
  - IMAP (mail only)
  - Zimbra
  - Office 365 (experimental)

## Prerequisites

Perform the following on the system on which you will be performing the migration (i.e. the migration workstation):

1. Install a Notes client (with Domino Administrator and Domino Designer) at version level 9.0.1 FP8. Note that this exact
   level is required.

2. Download and install the latest version of Transend Migrator from <http://www.transend.com/ftp/tm.msi>. Important! You must
   install the latest available version, which the link always points to.

3. Copy the on-prem Domino certifier ID to the migration workstation. For example, copy it to C:\IBM\IDs.

4. Update PowerShell to version 5 or later. You can get the current version of PowerShell by running the following command:

   ```PowerShell
   $PSVersionTable.PSVersion.Major
   ```

   If this returns a number less than 5, see <https://www.microsoft.com/en-us/download/details.aspx?id=50395> for details on 
   downloading a Windows update to upgrade the version.
	
5. If you are migrating from Exchange MAPI or PST files, install Outlook on the migration workstation and configure it as the
   default application for email.

## Step 1 - Setup

1. Copy setupTM.zip to the migration workstation's C:\Temp directory.

2. Unzip the contents of setupTM.zip to C:\Temp\TM.

3. Run setupTM.bat, which will create the necessary directories and files in C:\ProgramData\Transend. Note that you will 
   need to have Windows Explorer configured to display hidden folders. Click Organize -> Folder and search options -> View 
   tab and enable Show hidden files, folders, and drives.	

4. Copy C:\ProgramData\Transend\Templates\migration.ntf to the Domino mail server data directory. For example, copy it to 
   C:\IBM\Domino\Data.

5. Open the Domino Administration client and click File -> Open Server to connect to the mail server.

6. Click File -> Application -> New, change the server to the mail server, make the title Mail Migration, and set the file 
   name to migration.nsf. In the Template section, set the server to the mail server, click Show advanced templates, and 
   select the Mail Migration template (migration.ntf). Click OK.

7. Open the new migration.nsf application and the server names.nsf application in Domino Designer.

8. Navigate to migration.nsf -> Code -> Script Libraries.

9. Open the MigrationUtils script library and click on Declarations.

10. Update the DOMINO_MAIL_SERVER variable to point to your Domino server. For example, "Mail1/IBM."

11. Copy the MigrationUtils script library to names.nsf -> Code -> Script Libraries.

12. Navigate to migration.nsf -> Code -> Agents.

13. Select the Create\Address Translation Table and Create\Batch Migration Table agents and copy them to 
    names.nsf -> Code -> Agents.

14. Close Domino Designer and open migration.nsf in Domino Administrator.

15. Click Actions -> Update Configuration and fill out the fields in the form to match your environment. Click Save & Close 
    after filling out all fields.

You have now completed setup.

## Step 2a - Registering Users from Active Directory

Only perform this step if legacy user accounts are stored in Active Directory and you want to use MigrationUtils to register
those users in Domino. Skip this step if user accounts are stored in a different directory or you will register users in Domino
outside of MigrationUtils.

1. Open PowerShell and cd to C:\ProgramData\Transend\Bin.

2. Run .\getADUsers to see the options required for the getADUsers script.

3. Run .\getADUsers with the options for your environment and direct the output to a file named registration.ldif. For 
   example:

   ```PowerShell
   .\getADUsers "C:\IBM\Notes" "ldap.ibm.com" "cn=Administrator,cn=Users,dc=ibm,dc=com" "password" 
   "ou=Sales,dc=ibm,dc=com" "(&(cn=*)(objectClass=organizationalPerson))" > c:\ProgramData\Transend\Extras\registration.ldif
   ```

   The following are true in the example above:

  - The Notes client is installed in C:\IBM\Notes
  - The Active Directory server is ldap.ibm.com
  - The Active Directory administrator is cn=Administrator,cn=Users,dc=ibm,dc=com
  - The Active Directory administrator password is password
  - The search for users will begin at ou=Sales,dc=ibm,dc=com
  - The search will be for all users in ou=Sales,dc=ibm,dc=com

4. From migration.nsf, run the Register\Active Directory Users agent and select the registration.ldif file when prompted.

5. Confirm the users have been successfully registered and have mail files. If there are any problems, review 
   MigrationUtils.log, which is located in the directory you specified when running the Update Configuration agent in 
   Step 1.

6. Select all new user mail files and add the Domino administrator to the ACL as a Manager. Tip: you can add
   [LocalDomainAdmins] to the mail template ACL as Manager to propogate Manager access to all databases created from that
   template. Doing that means you don't need to perform this step each time you register new users.
	
Note: If you are changing the email addresses for users during migration, leave the old email address in the Person document
at this time. The old email address is needed to build the migration artifacts in later steps. You can change the email
address in the Person document after all parts of the Transend Migrator migration have been completed.

## Step 2b - Registering Users from Google Directory

Only perform this step if legacy user accounts are stored in Google Directory and you want to use MigrationUtils to register
those users in Domino. Skip this step if user accounts are stored in a different directory or you will register users in Domino
outside of MigrationUtils.

1. Open the Google Admin console and click Users -> More actions (three vertical dots in uppper right corner) -> Download 
   users. Select the Download all users option and uncheck the Create a Google spreadsheet option, which will save the user 
   list as a CSV.

2. From migration.nsf, run the Register\Google Users agent and select the CSV file you downloaded from the source mail 
   system.

3. Confirm the users have been successfully registered and have mail files. If there are any problems, review 
   MigrationUtils.log, which is located in the directory you specified when running the Update Configuration agent in 
   Step 1.

4. Select all new user mail files and add the Domino administrator to the ACL as a Manager if it is not already there.
   Tip: you can add [LocalDomainAdmins] to the mail template ACL as Manager to propogate Manager access to all databases 
   created from that template. Doing that means you don't need to perform this step each time you register new users.
	
Note: If you are changing the email addresses for users during migration, leave the old email address in the Person document
at this time. The old email address is needed to build the migration artifacts in later steps. You can change the email
address in the Person document after all parts of the Transend Migrator migration have been completed.

## Step 2c - Registering Users from Zimbra

Only perform this step if legacy user accounts are stored in Zimbra and you want to use MigrationUtils to register
those users in Domino. Skip this step if user accounts are stored in a different directory or you will register users in Domino
outside of MigrationUtils.

1. Open PowerShell and cd to C:\ProgramData\Transend\Bin.

2. Run .\getZimbraUsers to see the options required for the getZimbraUsers script.

3. Run .\getZimbraUsers with the options for your environment and direct the output to a file named registration.ldif. For 
   example:

   ```PowerShell
   .\getZimbraUsers "C:\IBM\Notes" "ldap.ibm.com" "uid=admin,ou=people,dc=ibm,dc=com" "password" 
   "ou=people,dc=ibm,dc=com" "(&(uid=*)(objectClass=inetOrgPerson))" > c:\ProgramData\Transend\Extras\registration.ldif
   ```

   The following are true in the example above:

  - The Notes client is installed in C:\IBM\Notes
  - The Zimbra server is ldap.ibm.com
  - The Zimbra administrator is uid=admin,ou=people,dc=ibm,dc=com
  - The Zimbra administrator password is password
  - The search for users will begin at ou=people,dc=ibm,dc=com
  - The search will be for all users in ou=people,dc=ibm,dc=com

4. From migration.nsf, run the Register\Zimbra Users agent and select the registration.ldif file when prompted.

5. Confirm the users have been successfully registered and have mail files. If there are any problems, review 
   MigrationUtils.log, which is located in the directory you specified when running the Update Configuration agent in 
   Step 1.

6. Select all new user mail files and add the Domino administrator to the ACL as a Manager. Tip: you can add
   [LocalDomainAdmins] to the mail template ACL as Manager to propogate Manager access to all databases created from that
   template. Doing that means you don't need to perform this step each time you register new users.

Note: If you are changing the email addresses for users during migration, leave the old email address in the Person document
at this time. The old email address is needed to build the migration artifacts in later steps. You can change the email
address in the Person document after all parts of the Transend Migrator migration have been completed.

## Step 2d - Registering Users from Office 365

Only perform this step if legacy user accounts are stored in Office 365 and you want to use MigrationUtils to register
those users in Domino. Skip this step if user accounts are stored in a different directory or you will register users in Domino
outside of MigrationUtils.

1. Open the Office 365 Admin center and navigate to Users -> Active users. Click the Export button and then click Continue. Save
   the resulting CSV file on the migration workstation.

2. From migration.nsf, run the Register\Office 365 Users agent and select the CSV file you downloaded from the source mail 
   system.

3. Confirm the users have been successfully registered and have mail files. If there are any problems, review 
   MigrationUtils.log, which is located in the directory you specified when running the Update Configuration agent in 
   Step 1.

4. Select all new user mail files and add the Domino administrator to the ACL as a Manager if it is not already there.
   Tip: you can add [LocalDomainAdmins] to the mail template ACL as Manager to propogate Manager access to all databases 
   created from that template. Doing that means you don't need to perform this step each time you register new users.
	
Note: If you are changing the email addresses for users during migration, leave the old email address in the Person document
at this time. The old email address is needed to build the migration artifacts in later steps. You can change the email
address in the Person document after all parts of the Transend Migrator migration have been completed.

## Step 2e - Registering Users from other directory sources

Only perform this step if user accounts are not stored in one of the directories MigrationUtils supports or you want to 
register users in Domino Directory manually. See the Supported platforms section and Steps 2a, 2b, 2c, and 2d for details.

1. Open Domino Administrator and use the File -> Open Server menu option to connect to the on-prem Domino mail server.

2. On the People & Groups tab, click Tools -> People -> Register.

3. Enter the certifier password and click OK.

4. Fill out the information for the user being registered, click the green check button, and click Register. Note: set the
   user's Mail system to IBM iNotes and select the option to store the user ID in the mail file on the ID Info pane.

5. Verify that the user is successfully registered and click OK.

Note: If you are changing the email addresses for users during migration, leave the old email address in the Person document
at this time. The old email address is needed to build the migration artifacts in later steps. You can change the email
address in the Person document after all parts of the Transend Migrator migration have been completed.

## Step 3 - Building a batch migration table

1. Select the users to be migrated in the batch from the People & Groups tab in Domino Administrator and run the 
   Create\Batch Migration Table agent. You can either select users individually or select a group containing users in the batch. A 
   useful technique is to create group documents that correspond with each batch (Batch 1, Batch 2, Batch 3, etc.) and add 
   the users for each batch to the appropriate group. Then select the group and run the Create\Batch Migration Doc agent.

2. Review the batch migration CSV file in C:\ProgramData\Transend\Batches. The file should contain the following fields for
   each user in the migration batch:

  - Legacy email address
  - Full path to the user's mail file, including the mail server
  - Notes canonical name

  If there are any problems, review MigrationUtils.log, which is located in the directory you specified when running the 
  Update Configuration agent in Step 1.

## Step 4 - Building an address migration table

1. Select all users that will be migrating from the People & Groups tab in Domino Administrator and run the Create\Address
   Translation Table agent. As with the Create\Batch Migration Table agent, you can select users individually or a group 
   containing the migrating users. You can also select multiple groups; for example, select the Batch 1, Batch 2 and Batch 3
   groups to build an address migration table for all users in the three groups.

   Unlike creating a batch migration table, all users who will migrate (not just those in the current batch) need to be 
   selected here. That's because all migrating users must have their old names mapped to new names when the batch is 
   migrated. If you only select users in the current batch, then users in other batches will be represented as old names in 
   the mail files of users in the current batch.

2. Review the address translation CSV in C:\ProgramData\Transend\Batches. The file should contain the following mappings for
   each user being migrated as part of the migration project:
 
  - Legacy email address to Notes canonical name
  - Legacy DN to the Notes canonical name

   If there are any problems, review MigrationUtils.log, which is located in the directory you specified when running the 
   Update Configuration agent in Step 1.

## Step 5 - Building a Transend Migrator configuration

1. From migration.nsf, run the Create\Transend Migrator Configuration agent. A new Transend Migrator TMD file will be 
   generated based on the information you specified when running the Update Configuration agent in Step 1.

2. Review the TMD file in C:\ProgramData\Transend\Configurations. If there are any problems, review the powershell.log file 
   in C:\ProgramData\Transend\Logs.
	
PST Note: MigrationUtils will create a PST configuration in which the name of the PST to be migrated is based on the user's
email address. For example, a user with email address tuser1@ibm.com is expected to have a PST file named tuser1@ibm.com.pst.
If your PST files do not follow this convention, you can either rename them or modify the configuration file to match your
environment.

## Step 6 - Performing the migration

1. Launch Transend Migrator and click File -> Open Configuration.

2. Select the TMD file created in Step 5, which will be located in C:\ProgramData\Transend\Configurations.

3. Click Batch Migration -> Batch Migration Setup.

4. On the Batch Mode Data tab, click the Load From File button and select the 
   C:\ProgramData\Transend\Batches\batch_migration_<datetime>.csv file. Click Open. You should see the users load in the 
   Batch Mode Data tab.
	
   IMAP note: If you are migrating from IMAP with the LOGIN authentication mechanism, you will need to manually enter user 
   passwords in the $Var4 column before proceeding to the next step.

5. Click the Address Translation tab and click the Load From File button. Select the 
   C:\ProgramData\Transend\Batches\address_translation_<datetime>.csv file and click Open. You should see the users load in 
   the Address Translation tab.

6. Click OK to return to the Transend Migrator main UI.

7. Click the Enable Migration checkboxes on the E-Mail, Address Book, Calendar, and Task/To Do tabs if they are not already
   enabled (they should be enabled by default).

8. Click the Start Batch Migration button.

9. Click the Yes button to continue the migration.

10. If there are any errors during the migration, review the Transend Migrator logs, which are located in
    C:\ProgramData\Transend\Logs.