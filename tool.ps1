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
