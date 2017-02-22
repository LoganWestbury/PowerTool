##########################################################
#   Created by Logan Westbury
#   22/02/2017

##########################################################
#   Start the clock

$start_time = Get-Date

##########################################################
#   Download and deploy latest updateScripts script 

$url_updateScripts = "https://raw.githubusercontent.com/LoganWestbury/PowerTool/master/updateScripts.ps1"
$output_updateScripts = ".\updateScripts.ps1"

#   Delete the file if it already exists
Write-Host("Checking to see if file already exists.")
If (Test-Path $output_updateScripts){
	Write-Host("File found. Deleting the file now.")
	Remove-Item $output_updateScripts
	Write-Host("File deleted.")
}
else {
	Write-Host("File does not already exist.")
}
#   Download the file from the given url
Write-Host("Downloading latest version from GitHub.")
Invoke-WebRequest -Uri $url_updateScripts -OutFile $output_updateScripts 
Write-Host("File downloaded.")

##########################################################
#   Download and deploy latest deployShortcut script 

$url_deployShortcuts = "https://raw.githubusercontent.com/LoganWestbury/PowerTool/master/deployShortcuts.ps1"
$output_deployShortcuts = ".\deployShortcuts.ps1"

#   Delete the file if it already exists
Write-Host("Checking to see if file already exists.")
If (Test-Path $output_deployShortcuts){
	Write-Host("File found. Deleting the file now.")
	Remove-Item $output_deployShortcuts
	Write-Host("File deleted.")
}
else {
	Write-Host("File does not already exist.")
}

#   Download the file from the given url
Write-Host("Downloading latest version from GitHub.")
Invoke-WebRequest -Uri $url_deployShortcuts -OutFile $output_deployShortcuts 
Write-Host("File downloaded.")

##########################################################
#   Display the output

[Environment]::NewLine
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
[Environment]::NewLine
Read-Host("Press any key to exit...")
