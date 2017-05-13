##########################################################
#   Import Required Modules
##########################################################

Import-Module ActiveDirectory

##########################################################
#   Display Console Window Header
##########################################################

function Display-Title {

    Clear-Host 
    $a = Get-Date

    $title = ("Power Scripts | Logan Westbury | Github.com/LoganWestbury/PowerTool | " + $a.ToUniversalTime() + " | " + $env:username)
    $border = "-" * ($title.length +4)
    $gap = " " * (($host.UI.RawUI.windowsize.width/2)-($title.length/2)-2)
    $gap2 = " " * ((($host.UI.RawUI.windowsize.width/2)-($title.length/2)-2)-1)
    Write-Host "`n$gap$border$gap2`n$gap| $title |$gap2`n$gap$border$gap2" -ForegroundColor White
    [Environment]::NewLine

}

##########################################################
#   Resolve Hostname from IP
##########################################################

function queryRemoteHost {
    [Environment]::NewLine
    $userQueryInput = Read-Host "Enter the hostname / IP address"
    
    # Call function to resolve a host name from an IP address
    $queryHostName = [System.Net.Dns]::GetHostEntry($userQueryInput).Hostname
	
    # Call function to resolve an IP address from a host name
    $queryIPAddress = [System.Net.Dns]::GetHostAddresses($userQueryInput)
		
    Write-Host ("Host: " + $queryHostName)
    Write-Host ("IP: " + $queryIPAddress)

    Get-SystemInfo -ComputerName $userQueryInput
	
    pressAnyKey
    
}