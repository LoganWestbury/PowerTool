Clear-Host

$userInput = Read-Host("Enter remote host")

$string1 = ""

$string1 = Get-WmiObject Win32_ComputerSystem -ComputerName $userInput -recurse | Where-Object {!$_.PsIsContainer} | foreach {$_.Username}

$string1 = $string1.Substring(4)

$createDir = ("\\$userInput\C$\Users\$string1\Desktop\")

New-Item "$createDir\Shortcuts\" -type directory
New-Item "$createDir\Shortcuts\Rev8" -type directory

$createDir = ("\\$userInput\C$\Users\$string1\Desktop\Shortcuts\")

Write-Host("Username: " + $string1)
Write-Host("Directory: " + $createDir)

Invoke-Expression "explorer $createDir"

$Shell = New-Object -ComObject ("WScript.Shell")

##########################################################
#   Create ASO 2 Link  

$ShortCutASO2 = $Shell.CreateShortcut("$createDir\ASO2.url") 
$ShortCutASO2.TargetPath="http://193.0.9.112/ASO2/login.aspx"
$ShortCutASO2.Save()

##########################################################
#   Create ASO 2.5 Link

$ShortCutASO25 = $Shell.CreateShortcut("$createDir\ASO2_5.url") 
$ShortCutASO25.TargetPath="http://193.0.9.112/ASO2-5/login.aspx"
$ShortCutASO25.Save()

##########################################################
#   Create Web Mail Link

$shortCutWebMail = $Shell.CreateShortcut("$createDir\WebMail.url") 
$shortCutWebMail.TargetPath="https://webmail.arnoldclark.com"
$shortCutWebMail.Save()

##########################################################
#   Create Salesmans Office Link

$shortCutSMO = $Shell.CreateShortcut("$createDir\Salesmans_Office.url") 
$shortCutSMO.TargetPath="http://10.6.1.1/salesmanoffice2/login.aspx"
$shortCutSMO.Save()

##########################################################
#   Copy over Rev8 shortcuts

Copy-Item -Path (".\resources\rev8\Rev8 Arnold Clark.kcc") -Destination ("$createDir\Rev8\") 
Copy-Item -Path (".\resources\rev8\Rev8 Harry Fairbairn.kcc") -Destination ("$createDir\Rev8\") 
Copy-Item -Path (".\resources\rev8\Rev8 John R Weir.kcc") -Destination ("$createDir\Rev8\") 
