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
	
	
	$menuItems = @(
		"Exit",
		"Remote Shutdown Checker",
		"Scan Active Directory for Locked Out Users",
		"User Lockout Location Checker",
		"Active Directory Query User with Employee ID",
		"Open Remote PC's C:\ Drive",
		"System Specs of Remote Host"
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

function scanADForLockedOutUsers
{

	textSeperateLine -inputString 'List of currently locked out users from Active Directory:'
	Search-ADAccount -LockedOut | Format-Table Name, LastLogonDate, PasswordExpired, PasswordNeverExpires, SamAccountName -Wrap


<#
$Write = ("Select a user account and then click Ok to scan the system for the location of the lockout.")
textSeperateLine $Write

 Search-ADAccount -LockedOut |
    Select-Object Name, SamAccountName, Enabled, LastLogonDate, PasswordExpired, PasswordNeverExpires | Out-GridView -PassThru -Title "List of Locked Out Accounts" | Foreach-Object { lockoutLocationFinder -Identity $_.SamAccountName}

#>
	
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

function queryRemoteHost
{
	[Environment]::NewLine
	[Environment]::NewLine
	$userQueryInput = Read-Host "Enter the hostname / IP address"
    
	# Call function to resolve a host name from an IP address
	$queryHostName = [System.Net.Dns]::GetHostEntry($userQueryInput).Hostname
	
	# Call function to resolve an IP address from a host name
	$queryIPAddress = [System.Net.Dns]::GetHostAddresses($userQueryInput)
	
	# Call function to get host version of Windows
	#$queryHostWinVersion = Get-WmiObject Win32_OperatingSystem -computername $userQueryInput -ea stop
	#$queryHostWinVersion = Get-WmiObject -class Win32_OperatingSystem -computername $userQueryInput
    #$queryHostWinVersion = get-wmiobject win32_computersystem -computer $userQueryInput | select-object Caption
	
	
	Write-Host ("Host: " + $queryHostName)
	Write-Host ("IP: " + $queryIPAddress)
	#Write-Host ("Windows Version: " + $queryHostWinVersion)
	
	
#	Get-WmiObject Win32_OperatingSystem -ComputerName $userQueryInput,2K8R2,WSUS,SOFSR2Node1,SOFSR2Node2 | Select-Object CSName,Caption,CSDVersion,@{Label="InstallDate";Expression={[System.Management.ManagementDateTimeConverter]::ToDateTime($($_.InstallDate))}},@{Label="LastBootUpTime";Expression={[System.Management.ManagementDateTimeConverter]::ToDateTime($($_.LastBootUpTime))}},MUILanguages,OSArchitecture,ServicePackMajorVersion,Version | Format-Table
	
	pressAnyKey
	
	
	
	
}


function Get-OS {
  Param([string]$computername=$(Throw "You must specify a computername."))
  Write-Debug "In Get-OS Function"
  $wmi=Get-WmiObject Win32_OperatingSystem -computername $computername -ea stop
  
  write $wmi

}





function queryRemoteHost_hostName
{

}


function displayMenu_mainMenu
{
do
{
	populateMainMenu
	$input = Read-Host "Select an option"
	
	switch ($input)
	{
		'1' {
			displayVersion
			displayMenu_activeDirectory
			pressAnyKey
		} '2' {
			displayVersion
			displayMenu_remoteTools
			pressAnyKey
		} ('0')
		{
			return
		}
	}
}
until ($input -eq '0')
}



displayMenu_mainMenu
