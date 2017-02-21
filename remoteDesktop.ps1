Clear-Host

$userInput = Read-Host("Enter remote host")

$string1 = ""

$string1 = Get-WmiObject Win32_ComputerSystem -ComputerName $userInput -recurse | Where-Object {!$_.PsIsContainer} | foreach {$_.Username}

$string1 = $string1.Substring(4)

$createDir = ("\\$userInput\C$\Users\$string1\Desktop\")

Write-Host("Username: " + $string1)
Write-Host("Directory: " + $createDir)

Invoke-Expression "explorer $createDir"



$Shell = New-Object -ComObject ("WScript.Shell")

$ShortCut = $Shell.CreateShortcut("$createDir\Google.url")

$ShortCut.TargetPath="www.google.com"

#$ShortCut.Arguments="-arguementsifrequired"

#$ShortCut.WorkingDirectory = "$createDir\";

#$ShortCut.WindowStyle = 1;

#$ShortCut.Hotkey = "CTRL+SHIFT+F";

#$ShortCut.IconLocation = "yourexecutable.exe, 0";

#$ShortCut.Description = "Google Shortcut";

$ShortCut.Save()


