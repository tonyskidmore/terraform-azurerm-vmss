Start-Transcript -Path "C:\WindowsAzure\Logs\Start-VmssConfig.log" -Append

$binDirectory = "C:\Users\Public\Downloads"
Set-Location -Path $binDirectory

$scriptFile = "C:\AzureData\Set-VmssInstance.ps1"
Copy-Item -Path "C:\AzureData\CustomData.bin" -Destination $scriptFile

. $scriptFile

Stop-Transcript
