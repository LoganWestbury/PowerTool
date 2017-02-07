Import-Module ActiveDirectory

function pressAnyKey
{
	# Wait for user to press any key to continue, gives user time to read output
	textSeperateLine -inputString "Press any key to continue..."
	$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
	$HOST.UI.RawUI.Flushinputbuffer()
}

function populateMainMenu
{
	#$totalDir = Get-Location
	Import-Module howMenuReusable.psm1
	
	$menuItems = @(
		"Exit",
		"Remote Shutdown Checker",
		"Scan Active Directory for Locked Out Users",
		"User Lockout Location Checker",
		"Active Directory Query User with Employee ID"
		"Open Remote PC's C:\ Drive"
	)
	
	showMenuReusable -menuItems $menuItems
}

function displayVersion
{
	Clear-Host
	$runasAlias = [Environment]::UserName
	Write-Host ("/---------------------------------------------------------------\")
	Write-Host ("|--------------------------Help Desk----------------------------|")
	Write-Host ("\---------------------------------------------------------------/")
	
	[Environment]::NewLine
	
	Write-Host ("If you recieve any error messages could you please send a screenshot to Logan.Westbury@ArnoldClark.com") -ForegroundColor Yellow
	Write-Host ("To temporarily fix most issues just relaunch the program.") -ForegroundColor Yellow
	[Environment]::NewLine
}


do
{
	populateMainMenu
	$input = Read-Host "Select an option"
	
	switch ($input)
	{
		'1' {
			displayVersion
			Write-Host ("Event Viewer Remote Shutdown Checker")
			[Environment]::NewLine
			remoteShutdownChecker
			pressAnyKey
			
		} '2' {
			displayVersion
			scanADForLockedOutUsers
			pressAnyKey
			
		} '3' {
			displayVersion
			Write-Host ("User Lockout Checker")
			[Environment]::NewLine
			Write-Host ("Known Issue - For every user you check for lockouts, you  must restart the application.") -ForegroundColor Yellow
			[Environment]::NewLine
			Write-Host ("May take about 30 seconds to complete. Do not press anything else until it has completed.") -ForegroundColor Yellow
			[Environment]::NewLine
			$identity = Read-Host 'Input User ID (e00 etc)'
			[Environment]::NewLine
			lockoutLocationFinder -Identity $identity
			pressAnyKey
			
		} '4' {
			displayVersion
			Write-Host ("Active Directory Query User with Employee ID")
			[Environment]::NewLine
			$employeeID = Read-Host 'Input Employee ID (e00 etc)'
			queryActiveDirectoryUser -employeeID $employeeID
			pressAnyKey
			
		} '5' {
			displayVersion
			openRemoteDrive
			pressAnyKey
		} ('0')
		{
			return
		}
	}
}
until ($input -eq '0')
