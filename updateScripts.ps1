##########################################################
#   Created by Logan Westbury
#   22/02/2017

$start_time = Get-Date



##########################################################
#   Download latest deployShortcut script 

$url_deployShortcuts = "https://raw.githubusercontent.com/LoganWestbury/PowerTool/master/deployShortcuts.ps1"
$output_deployShortcuts = ".\deployShortcuts.ps1"
If (Test-Path $output_deployShortcuts){
	Remove-Item $output_deployShortcuts
}

Invoke-WebRequest -Uri $url_deployShortcuts -OutFile $output_deployShortcuts 





[Environment]::NewLine
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
Read-Line("Press any key to exit...")
[Environment]::NewLine

