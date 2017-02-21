Clear-Host

$userInput = Read-Host("Enter remote host")

$string1 = ""

$string1 = Get-WmiObject Win32_ComputerSystem -ComputerName $userInput -recurse | Where-Object {!$_.PsIsContainer} | foreach {$_.Username}

$string1 = $string1.Substring(4)

$createDir = ("\\$userInput\C$\Users\$string1\Desktop\")

Write-Host("Username: " + $string1)
Write-Host("Directory: " + $createDir)

Invoke-Expression "explorer $createDir"
