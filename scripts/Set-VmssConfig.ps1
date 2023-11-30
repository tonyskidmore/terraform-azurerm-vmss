$ProgressPreference = 'SilentlyContinue'

function ConvertFrom-Base64 {
  param(
    [Parameter(Mandatory = $true,
    ValueFromPipeline = $true,
    Position = 0)]
    [string]$Base64String
  )
  $bytes = [System.Convert]::FromBase64String($Base64String)
  $utf8 = [System.Text.Encoding]::UTF8.GetString($bytes)
  $utf8
}

function Get-Imds {
  Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" | ConvertTo-Json -Depth 64
}

function Get-UserData {
  $imds = Get-Imds | ConvertFrom-Json
  $base64 = $imds.compute | Select-Object -ExpandProperty "userData"
  ConvertFrom-Base64 -Base64String $base64
}

function Install-AzPowershellModule {
  $AzModule = Get-Module -ListAvailable -Name Az -ErrorAction SilentlyContinue
  if ($null -eq $AzModule) {
      Write-Host "Installing Az PowerShell Module..."
      Install-Module -Name Az -Scope AllUsers -Force
  }
}

function Install-AzureCli {
    $AzureCli = Get-Command az -ErrorAction SilentlyContinue
    if ($null -eq $AzureCli) {
        Write-Host "Installing Azure CLI..."
        Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
        Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
        Remove-Item .\AzureCLI.msi
    }
}
function Install-Docker {
  # https://learn.microsoft.com/en-us/virtualization/windowscontainers/quick-start/set-up-environment?tabs=dockerce#windows-server-1
  Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
  .\install-docker-ce.ps1
}

function Install-Pwsh {
  $Pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
  if ($null -eq $Pwsh) {
      Write-Host "Installing PowerShell Core..."
      Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.4.0/PowerShell-7.4.0-win-x64.msi -OutFile .\PowerShell-7.4.0-win-x64.msi
      Start-Process msiexec.exe -Wait -ArgumentList '/package PowerShell-7.4.0-win-x64.msi /quiet REGISTER_MANIFEST=1 USE_MU=1 ENABLE_MU=1 ADD_PATH=1'
      Remove-Item .\PowerShell-7.4.0-win-x64.msi
  }
}

function Install-Terraform {
  param(
    [string]$Version = "latest"
  )

  $SaveToPath = "C:\ProgramData\Tools"
  $Terraform= Get-Command terraform -ErrorAction SilentlyContinue
  if ($null -eq $Terraform) {
      Write-Host "Installing Terraform..."
      if ($Version -eq "latest") {
        $releasesUrl = 'https://api.github.com/repos/hashicorp/terraform/releases'
        $releases = Invoke-RestMethod -Method Get -UseBasicParsing -Uri $releasesUrl
        $Version = $releases.Where({!$_.prerelease})[0].name.trim('v')
        Write-Host "Latest Terraform version is $Version"
      }
      $terraformFile = "terraform_${Version}_windows_amd64.zip"
      $terraformURL = "https://releases.hashicorp.com/terraform/${Version}/${terraformFile}"

      $download = Invoke-WebRequest -UseBasicParsing -Uri $terraformURL -DisableKeepAlive -OutFile "${env:Temp}\${terraformFile}" -ErrorAction SilentlyContinue -PassThru

      if (($download.StatusCode -eq 200) -and (Test-Path "${env:Temp}\${terraformFile}")) {
        Unblock-File "${env:Temp}\${terraformFile}"
        Start-Sleep -Seconds 10
        Expand-Archive -Path "${env:Temp}\${terraformFile}" -DestinationPath $SaveToPath -Force

        Remove-Item -Path "${env:Temp}\${terraformFile}" -Force

        Write-Host "Terraform version $Version installed to $SaveToPath"

        # Save the path to the Terraform executable permanently to the PATH environment variable
        $path = [Environment]::GetEnvironmentVariable('Path','Machine')
        [Environment]::SetEnvironmentVariable('PATH', "${path};${SaveToPath}", 'Machine')
      }
  }
}

Get-Imds | Out-File -FilePath "C:\AzureData\IMDS.json"

$userData = Get-UserData | ConvertFrom-Json

foreach ($install in $userData.install) {
  Write-Host "Calling function Install-$($install)..."
  & "Install-$($install)"
}

# Install-AzureCli
# Install-Pwsh
# Install-Terraform
# Troublesome:
# Install-Docker
# Install-AzPowershellModule
