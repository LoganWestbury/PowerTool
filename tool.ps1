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


function openRemoteDrive
{
	$remoteIP = Read-Host 'Input Remote IP / Terminal Name'
	
	Invoke-Expression "explorer \\$remoteIP\c$"
	
}


function textSeperateLine
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[String]$inputString
	)
	
	[Environment]::NewLine
	Write-Host $inputString
	[Environment]::NewLine
}

function showMenuReusable
{
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True)]
		[Array]$menuItems
	)
	[Array]$tempMenuArray = $menuItems
	
	displayVersion
	$menuCounter = $tempMenuArray.Length
	$i = 0
	
	do
	{
		Write-Host ("Option $i : " + $tempMenuArray[$i])
		[Environment]::NewLine
		$i++
	}
	until ($i -eq $menuCounter)
}

function remoteShutdownChecker
{
	
	
	# Script for displaying scanning the event log of a remote PC and displaying when the PC has been shutdown/restarted.
	# LW - 16/09/2016 
	# Version 1.1
	# Added - Displaying a counter for how many times the PC has been shutdown.
	
	# Begin Script
	
	$amountOfDays = 90
	
	# Setting the filter - saves resources by not scanning the entire event log
	$FilterLog = @{
		# Sets which part of the event log to search (Security, System etc...)
		LogName = "System"
		# Sets how far back in the log to check
		StartTime = (Get-Date).AddDays(- $amountOfDays)
		# Set the filter for the event log to the ID '6006' 
		ID = 6006
	}
	
	# Get User input for remote IP 
	$remoteIP = Read-Host 'Input Remote IP / Terminal Name'
	
	# This section actually searches remote PC for shutdowns and puts the output into the variable
	$Events = Get-WinEvent -ComputerName $remoteIP -FilterHashtable $FilterLog
	
	# Count the amount of times the event has happened. In this case it is how many times the PC has been shut down.
	$amountOfRestarts = $Events.Count
	
	# Displaying how many times the PC has been restarted to console 
	textSeperateLine -inputString "The PC with IP $remoteIP has been shut down $amountOfRestarts times in the last $amountOfDays days."
	
	# Display to console the output log
	Get-WinEvent -ComputerName $remoteIP -FilterHashtable $FilterLog | Format-Table -AutoSize
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
