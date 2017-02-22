##########################################################
#   Created by Logan Westbury
#   22/02/2017

##########################################################
#   Start the clock

$start_time = Get-Date

##########################################################
#   Download latest deployShortcut script 

$url_deployShortcuts = "https://raw.githubusercontent.com/LoganWestbury/PowerTool/master/deployShortcuts.ps1"
$output_deployShortcuts = ".\deployShortcuts.ps1"

##########################################################
#   Delete the file if it already exists

If (Test-Path $output_deployShortcuts){
	Remove-Item $output_deployShortcuts
}

##########################################################
#   Download the file from the given url
Invoke-WebRequest -Uri $url_deployShortcuts -OutFile $output_deployShortcuts 

##########################################################
#   Display the output

[Environment]::NewLine
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
[Environment]::NewLine
Read-Host("Press any key to exit...")
