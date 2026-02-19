# NASAccess
Powershell Script packaged as an EXE that is able to map and un-map user accounts as a mounted drive for private storage

## The Powershell Script
### Controlling Variables
- The only modification needed if things break should be the 4 variables at the top of the program
  - $DriveLetter should always be set to M: there shouldnt be a scenario where something else is occupying that mount point. 
  - $ServerName is the IP Address of the NAS itself. This should remain the same unless the router is somehow messed with. To fix errors regarding the IP make sure to go into the router and either statically set the IP to the one in the script or change the script to reflect the new IP. 
  - $ShareName should NEVER be changed otherwise the NAS will lock it out as a security measure for permission creeping, leave this as is. 
  - $UNC (Universal Naming Convention) is used to assemble the share path for which is getting mounted to the system. This is comprised of the $ShareName and $serverName variables, so this will not need to be modified.

### Script Workflow (By Function)
- The *Show Menu* function is just a display function that writes to the host (console) the different fucntions the user is able to do.
- The *Clear-ConnectionsToIP* function is a fault tolerance function that is used when loggging in. When called upon it is going to check and clear out any served connections currently running toward the NAS at execution time. This runs quitely as a background function no visible to users.
- The *Login-Drive* Function is the login function that first is going to call upon user input for their credentials, and then sever any current connections if applicable. Then it will take the credentials to login to the share on the NAS and mount that folder to the M: drive
  - If there is an error code thrown please check credentials or if the account is logged in on another machine, then restart script. The NAS does not support multi-host logins
- The *Logout-Drive* Function is the logout function that is going to delete access to the share connection and remove the cached data that may persist that connection, then it will unmap the M: Drive ensuring a full and secure logout from that NAS folder.

## Packaging as an EXE
- If you have to update the application you first have to edit the powershell script and then use a quick downloadable powershell module **PS2EXE**.
- You will run the following commands in PowerShell below in order to convert the .ps1 file to an EXE
    `Install-Module ps2exe -Scope CurrentUser`

    `powershell -ExecutionPolicy Bypass`

    `Import-Module ps2exe`
  
    `ps2exe .\NASLogout.ps1 .\NASAccess.exe -iconFile .\tcs.ico`
  
   - The .\ is telling powershell to run and deposit the files in the current running directory, either put the files needed in the current running directory or update the command to reflect the directory the files are in
