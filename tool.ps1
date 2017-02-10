Import-Module ActiveDirectory

function pressAnyKey {
    # Wait for user to press any key to continue, gives user time to read output
    textSeperateLine -inputString "Press any key to continue..."
    $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

function openRemoteDrive {
    $remoteIP = Read-Host 'Input Remote IP / Terminal Name'
    Invoke-Expression "explorer \\$remoteIP\c$"
}


function textSeperateLine {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [String]$inputString
    )
	
    [Environment]::NewLine
    Write-Host $inputString
    [Environment]::NewLine
}

function Get-SystemInfo {
    param(
        [Parameter(Mandatory=$true)] $ComputerName,
        [switch] $IgnorePing
    )


    $computer = $ComputerName

    # Declare main data hash to be populated later
    $data = @{}

    $data.'ComputerName'=$computer

    # Try an ICMP ping the only way Powershell knows how...
    $ping = Test-Connection -quiet -count 1 $computer
    $Ping = $(if ($ping) {
        'Yes' 
    } else {
        'No' 
    })

# Do a DNS lookup with a .NET class method. Suppress error messages.
$ErrorActionPreference = 'SilentlyContinue'
if ( $ips = [System.Net.Dns]::GetHostAddresses($computer) | foreach { $_.IPAddressToString } ) {
    
    $data.'IP Address(es) from DNS' = ($ips -join ', ')
    
}

else {
    
    $data.'IP Address from DNS' = 'Could not resolve'
    
}
# Make errors visible again
$ErrorActionPreference = 'Continue'

# We'll assume no ping reply means it's dead. Try this anyway if -IgnorePing is specified
if ($ping -or $ignorePing) {
    
    $data.'WMI Data Collection Attempt' = 'Yes (ping reply or -IgnorePing)'
    
    # Get various info from the ComputerSystem WMI class
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_ComputerSystem -ErrorAction SilentlyContinue) {
        
        $data.'Computer Hardware Manufacturer' = $wmi.Manufacturer
        $data.'Computer Hardware Model'        = $wmi.Model
        $data.'Memory Physical in MB'          = ($wmi.TotalPhysicalMemory/1MB).ToString('N')
        $data.'Logged On User'                 = $wmi.Username
        
    }
    
    $wmi = $null
    
    # Get the free/total disk space from local disks (DriveType 3)
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction SilentlyContinue) {
        
        $wmi | Select 'DeviceID', 'Size', 'FreeSpace' | Foreach {
            
            $data."Local disk $($_.DeviceID)" = ('' + ($_.FreeSpace/1MB).ToString('N') + ' MB free of ' + ($_.Size/1MB).ToString('N') + ' MB total space with ' + ($_.Size/1MB - $_.FreeSpace/1MB).ToString('N') +' MB Used Space')
            
            
        }
        
    }
    
    $wmi = $null
    
    # Get IP addresses from all local network adapters through WMI
    if ($wmi = Get-WmiObject -Computer $computer -Class Win32_NetworkAdapterConfiguration -ErrorAction SilentlyContinue) {
        
        $Ips = @{}
        
        $wmi | Where { $_.IPAddress -match '\S+' } | Foreach { $Ips.$($_.IPAddress -join ', ') = $_.MACAddress }
        
    $counter = 0
    $Ips.GetEnumerator() | Foreach {
            
        $counter++; $data."IP Address $counter" = '' + $_.Name + ' (MAC: ' + $_.Value + ')'
            
    }
        
}
    
$wmi = $null
    
# Get CPU information with WMI
if ($wmi = Get-WmiObject -Computer $computer -Class Win32_Processor -ErrorAction SilentlyContinue) {
        
    $wmi | Foreach {
            
        $maxClockSpeed     =  $_.MaxClockSpeed
        $numberOfCores     += $_.NumberOfCores
        $description       =  $_.Description
        $numberOfLogProc   += $_.NumberOfLogicalProcessors
        $socketDesignation =  $_.SocketDesignation
        $status            =  $_.Status
        $manufacturer      =  $_.Manufacturer
        $name              =  $_.Name
            
    }
        
    $data.'CPU Clock Speed'        = $maxClockSpeed
    $data.'CPU Cores'              = $numberOfCores
    $data.'CPU Description'        = $description
    $data.'CPU Logical Processors' = $numberOfLogProc
    $data.'CPU Socket'             = $socketDesignation
    $data.'CPU Status'             = $status
    $data.'CPU Manufacturer'       = $manufacturer
    $data.'CPU Name'               = $name -replace '\s+', ' '
        
}
    
$wmi = $null
    
# Get BIOS info from WMI
if ($wmi = Get-WmiObject -Computer $computer -Class Win32_Bios -ErrorAction SilentlyContinue) {
        
    $data.'BIOS Manufacturer' = $wmi.Manufacturer
    $data.'BIOS Name'         = $wmi.Name
    $data.'BIOS Version'      = $wmi.Version
        
}
    
$wmi = $null
    
# Get operating system info from WMI
if ($wmi = Get-WmiObject -Computer $computer -Class Win32_OperatingSystem -ErrorAction SilentlyContinue) {
        
    $data.'OS Boot Time'     = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
    $data.'OS System Drive'  = $wmi.SystemDrive
    $data.'OS System Device' = $wmi.SystemDevice
    $data.'OS Language     ' = $wmi.OSLanguage
    $data.'OS Version'       = $wmi.Version
    $data.'OS Windows dir'   = $wmi.WindowsDirectory
    $data.'OS Name'          = $wmi.Caption
    $data.'OS Install Date'  = $wmi.ConvertToDateTime($wmi.InstallDate)
    $data.'OS Service Pack'  = [string]$wmi.ServicePackMajorVersion + '.' + $wmi.ServicePackMinorVersion
        
}
    
# Scan for open ports
$ports = @{ 
    'File shares/RPC' = '139' ;
    'File shares'     = '445' ;
    'RDP'             = '3389';
    #'Zenworks'        = '1761';
}
    
foreach ($service in $ports.Keys) {
        
    $socket = New-Object Net.Sockets.TcpClient
        
    # Suppress error messages
    $ErrorActionPreference = 'SilentlyContinue'
        
    # Try to connect
    $socket.Connect($computer, $ports.$service)
        
    # Make error messages visible again
    $ErrorActionPreference = 'Continue'
        
    if ($socket.Connected) {
            
        $data."Port $($ports.$service) ($service)" = 'Open'
        $socket.Close()
            
    }
        
    else {
            
        $data."Port $($ports.$service) ($service)" = 'Closed or filtered'
            
    }
        
    $socket = $null
        
}
    
}

else {
    
    $data.'WMI Data Collected' = 'No (no ping reply and -IgnorePing not specified)'
    
}

$wmi = $null


if ($wmi = Get-WmiObject -Class Win32_OperatingSystem -computername $Computer -ErrorAction SilentlyContinue| Select-Object Name, TotalVisibleMemorySize, FreePhysicalMemory,TotalVirtualMemorySize,FreeVirtualMemory,FreeSpaceInPagingFiles,NumberofProcesses,NumberOfUsers ) {
        
    $wmi | Foreach {
            
        $TotalRAM     =  $_.TotalVisibleMemorySize/1MB
        $FreeRAM     = $_.FreePhysicalMemory/1MB
        $UsedRAM       =  $_.TotalVisibleMemorySize/1MB - $_.FreePhysicalMemory/1MB
        $TotalRAM = [Math]::Round($TotalRAM, 2)
        $FreeRAM = [Math]::Round($FreeRAM, 2)
        $UsedRAM = [Math]::Round($UsedRAM, 2)
        $RAMPercentFree = ($FreeRAM / $TotalRAM) * 100
        $RAMPercentFree = [Math]::Round($RAMPercentFree, 2)
        $TotalVirtualMemorySize  = [Math]::Round($_.TotalVirtualMemorySize/1MB, 3)
        $FreeVirtualMemory =  [Math]::Round($_.FreeVirtualMemory/1MB, 3)
        $FreeSpaceInPagingFiles            =  [Math]::Round($_.FreeSpaceInPagingFiles/1MB, 3)
        $NumberofProcesses      =  $_.NumberofProcesses
        $NumberOfUsers              =  $_.NumberOfUsers
            
    }
    $data.'Memory - Total RAM GB '  = $TotalRAM
    $data.'Memory - RAM Free GB'    = $FreeRAM
    $data.'Memory - RAM Used GB'    = $UsedRAM
    $data.'Memory - Percentage Free'= $RAMPercentFree
    $data.'Memory - TotalVirtualMemorySize' = $TotalVirtualMemorySize
    $data.'Memory - FreeVirtualMemory' = $FreeVirtualMemory
    $data.'Memory - FreeSpaceInPagingFiles' = $FreeSpaceInPagingFiles
    $data.'NumberofProcesses'= $NumberofProcesses
    $data.'NumberOfUsers'    = $NumberOfUsers -replace '\s+', ' '
        
}

# Output data
"#"*80
"OS Complete Information"
"Generated $(get-date)"
"Generated from $(gc env:computername)"
"#"*80



$data.GetEnumerator() | Sort-Object 'Name' | Format-Table -AutoSize
$data.GetEnumerator() | Sort-Object 'Name' | Out-GridView -Title "$computer Information"

}




function remoteShutdownChecker {
	
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

function scanADForLockedOutUsers {

    textSeperateLine -inputString 'List of currently locked out users from Active Directory:'
    Search-ADAccount -LockedOut | Format-Table Name, LastLogonDate, PasswordExpired, PasswordNeverExpires, SamAccountName -Wrap


    <#
$Write = ("Select a user account and then click Ok to scan the system for the location of the lockout.")
textSeperateLine $Write

 Search-ADAccount -LockedOut |
    Select-Object Name, SamAccountName, Enabled, LastLogonDate, PasswordExpired, PasswordNeverExpires | Out-GridView -PassThru -Title "List of Locked Out Accounts" | Foreach-Object { lockoutLocationFinder -Identity $_.SamAccountName}

#>
	
}

function displayVersion {
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

function queryRemoteHost {
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

    Get-SystemInfo -ComputerName $userQueryInput
	
	
    #	Get-WmiObject Win32_OperatingSystem -ComputerName $userQueryInput,2K8R2,WSUS,SOFSR2Node1,SOFSR2Node2 | Select-Object CSName,Caption,CSDVersion,@{Label="InstallDate";Expression={[System.Management.ManagementDateTimeConverter]::ToDateTime($($_.InstallDate))}},@{Label="LastBootUpTime";Expression={[System.Management.ManagementDateTimeConverter]::ToDateTime($($_.LastBootUpTime))}},MUILanguages,OSArchitecture,ServicePackMajorVersion,Version | Format-Table
	
    pressAnyKey

    
}


function queryActiveDirUser{
    $queryUserInput = Read-Host("Enter username: ")
    Get-ADUser $queryUserInput -properties CN, Company, Department, EmailAddress, SamAccountName, Enabled, physicalDeliveryOfficeName
    net user $queryUserInput /domain
}

function Get-OS {
    Param([string]$computername=$(Throw "You must specify a computername."))
Write-Debug "In Get-OS Function"
$wmi=Get-WmiObject Win32_OperatingSystem -computername $computername -ea stop
  
Write-Output $wmi

}

function findUserComputerLogin {
    $inputUserName = ""
    $FILESERVER = ""

    $inputUserName = Read-Host "Please enter the Primary  user"

    
    # Connect Remotely to Server, Run Session, get a list of everybody logged in there 

    $S = New-PSSession –computername $FILESERVER 
    $Results = (INVOKE-COMMAND –Session $s –scriptblock { (NET SESSION) }) | Select-string $inputUserName 
    Remove-PSSession $S
    # parse through the data and pull out what we need   
    Foreach ( $Part in $RESULTS ) {
        $ComputerIP=$Part.Line.substring(2,21).trim() 
        $User = $Part.Line.substring(21,44).trim()
        # Use nslookup to identify the computer, grab the line with the “Name:” field in it
        $Computername=([System.Net.dns]::GetHostbyAddress("$ComputerIP"))
        $computername =  $ComputerName.HostName
        If ($Computername -eq $NULL) {
            $Computername = ”Unknown”
        } 
        #Else { $Computername=$Computername.substring(9).trim()}
        If($User -eq $null){
            write-host "No computer found for $Username, Please check the name and try again. 'n A partial samaccountname works best"
        }
        else{
            write-host 
            # show what computer/s they are using
            “$User is logged into $Computername with IP address $ComputerIP”
            $global:findusercomputer = $computername
        }
    }
}









function activeDirListGroupMembers{
    $queryUserInput = Read-Host("Enter group name: ")
    Get-ADGroupMember $queryUserInput | select-object name | sort-object name
}

function showMenuReusable {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [Array]$menuItems
    )
    [Array]$tempMenuArray = $menuItems
	
    displayVersion
    $menuCounter = $tempMenuArray.Length
    $i = 0
	
    do {
        Write-Host ("Option $i : " + $tempMenuArray[$i])
        [Environment]::NewLine
        $i++
    }
    until ($i -eq $menuCounter)
}

function populateMenu_activeDirectory {
    $menuItems = @(
        "Return",
        "Scan AD for Locked Out Users",
        "User Lockout Location Checker",
        "Query User with Employee ID",
        "Reset Users Password",
        "List Members of a Group",
        "Find Computer via User"
    )
	
    showMenuReusable -menuItems $menuItems
}

function displayMenu_activeDirectory {
    do {
        populateMenu_activeDirectory
        $input = Read-Host "Select an option"
	
        switch ($input) {
            '1' {
                displayVersion
                Write-Host("Scan AD for Locked Out Users")
                scanADForLockedOutUsers
                pressAnyKey
            } '2' {
                displayVersion
                Write-Host("User Lockout Location Checker")
                
                pressAnyKey
            } '3' {
                displayVersion
                Write-Host("Query User with Employee ID")
                queryActiveDirUser
                pressAnyKey
            } '4' {
                displayVersion
                Write-Host("Reset Users Password")
                activeDirUserPassReset
                pressAnyKey
            } '5' {
                displayVersion
                Write-Host("List Members of a Group")
                activeDirListGroupMembers
                pressAnyKey
            }  '6' {
                displayVersion
                Write-Host("Find Computer via User")
                findUserComputerLogin
                pressAnyKey
            }  ('0') {
                return
            }
        }
    }
    until ($input -eq '0')
}

function populateMenu_remoteTools {	
    $menuItems = @(
        "Return",
        "Remote Shutdown Checker",
        "Open Remote PC's C:\ Drive",
        "System Specs of Remote Host"
    )
	
    showMenuReusable -menuItems $menuItems
}

function displayMenu_remoteTools {
    do {
        populateMenu_remoteTools
        $input = Read-Host "Select an option"
	
        switch ($input) {
            '1' {
                displayVersion
                Write-Host("Remote Shutdown Checker")
                
                pressAnyKey
            } '2' {
                displayVersion
                Write-Host("Open Remote PC's C:\ Drive")
                
                pressAnyKey
            } '3' {
                displayVersion
                Write-Host("System Specs of Remote Host")
                queryRemoteHost
                pressAnyKey
            } ('0') {
                return
            }
        }
    }    
    until ($input -eq '0')
}

function populateMenu_mainMenu {
    $menuItems = @(
        "Exit",
        "Active Directory Sub Menu",
        "Remote Tools Sub Menu"
    )
    showMenuReusable -menuItems $menuItems
}

function displayMenu_mainMenu {
    do {
        populateMenu_mainMenu
        $input = Read-Host "Select an option"
	
        switch ($input) {
            '1' {
                displayVersion
                displayMenu_activeDirectory
                pressAnyKey
            } '2' {
                displayVersion
                displayMenu_remoteTools
                pressAnyKey
            } ('0') {
                return
            }
        }
    }
    until ($input -eq '0')
}

# Program starts here
displayMenu_mainMenu
