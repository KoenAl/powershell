 #Copyright 
#This script will install all the dependencies on a new web box 
#Koen
#0 Letting the folks back home know it started
Set-ExecutionPolicy Unrestricted -scope Process -Force

$computername = $env:computername
Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Status':'start'}"
$endresult = 0
$testpath = Test-Path  'C:\PSLog'
if ($testpath -eq 'true')

{ write-host 'Log directory already exsits, skipping creation' -ForegroundColor Green
}

else

{ write-host 'Created Log directory' -ForegroundColor yellow
New-Item -ItemType directory -Path C:\PSLog

 }

$logdate = get-date -Format ddMMyyyy-hh-mm-ss
write-host $logdate
Start-Transcript -Path "C:\PSLog\$logdate.txt" -Force


#1 Powershell Version check

$Majorversion = $PSVersionTable.PSVersion.Major


[math]::Round($Majorversion)


if ($Majorversion -ne '5')

{
write-host 'Powershell 5 not installed. installing now' -ForegroundColor yellow

update-help -force


}

else
{
write-host 'latest version powershell installed' -ForegroundColor Green



}

#1.1 nuget check
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
$targetNugetExe = "$rootPath\nuget.exe"
Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
Set-Alias nuget $targetNugetExe -Scope Global -Verbose

#2 install Choco

$testchoco = powershell choco -v
if(-not($testchoco)){
    Write-Output "Seems Chocolatey is not installed, installing now"
    Set-ExecutionPolicy -confirm:$false Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    Start-Sleep -s 5
    Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Status':'fail'}"
    Start-Process -FilePath 'C:\webinstallation.ps1'
    Exit
}
else{
    Write-host "Chocolatey Version $testchoco is already installed"  -ForegroundColor Green

}

# or

if(test-path "C:\ProgramData\chocolatey\choco.exe"){

}
start-sleep -Seconds 15
refreshenv



choco install dotnet4.7



# 3 Install Azure RM

Write-Host "Checking for Module Azure RM" -ForegroundColor yellow
if (Get-Module -ListAvailable -Name 'AzureRM') {
    Write-Host "Module AzureRM exists" -ForegroundColor Green
} 
else {
    Write-Host "Module AzureRM does not exist... installing" -ForegroundColor Red
    Install-Module -Name AzureRM -AllowClobber -force -verbose 
    Write-Host "Moving onto AZ module (not azurerm)" -ForegroundColor yellow


    refreshenv
}

# 4 install notepad++ 32bit

choco install notepadplusplus --x86 --force -y
$testpath = Test-Path  'C:\Program Files\Notepad++'
if ($testpath -eq 'true')

{ }


# 5 install winrar

choco install winrar --force -y
$testpath = Test-Path  'C:\Program Files\WinRAR'
if ($testpath -eq 'true')

{ }

# 6 install visual studio community 2017

choco install visualstudio2017community --force -y
$testpath = Test-Path  'C:\Program Files (x86)\Microsoft Visual Studio'
if ($testpath -eq 'true')

{ }

# 7 install tortoise svn 64 bit

choco install tortoisesvn --force -y
$testpath = Test-Path  'C:\Program Files\TortoiseSVN'
if ($testpath -eq 'true')

{ }
# 8 Downoad azure file sync for windows server 2019
New-Item -ItemType directory -force -Path C:\sync 

#2016
$getOS = (Get-WMIObject win32_operatingsystem).name
write-host $getOs

if ($GETOS -like 'Microsoft Windows Server 2016 Standard|C:\Windows|')

{write-host 'Windows server 2016 detected...downloading 2016 version of Azure File Sync'  -ForegroundColor yellow

$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "StorageSyncAgent_WS2016.msi"
$TargetFolderPath = 'C:\sync'
$context = New-AzureStorageContext `
StorageAccountName = "INSERTACCOUNTHERE" -StorageAccountKey $StorageAccountKey
$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath }
elseif ($GETOS -like 'Microsoft Windows Server 2019 Standard|C:\Windows|')

{write-host 'Windows server 2019 detected...downloading 2019 version of Azure File Sync' -ForegroundColor yellow 


$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "StorageSyncAgent_WS2019.msi"
$TargetFolderPath = 'C:\sync'
$context = New-AzureStorageContext `
-StorageAccountName $StorageAccountName = "INSERTACCOUNTHERE" 
-StorageAccountKey $StorageAccountKey
$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath} 
else

{
write-host 'Unknown operating system' -ForegroundColor Red
}



# 8.1 install azurefilesync with default settings

#2016
$testpath = Test-Path  'C:\sync\StorageSyncAgent_WS2016.msi'

if ($testpath -eq 'true')

{ write-host 'installing StorageSyncAgent_WS2016.msi' -ForegroundColor Yellow
Invoke-Command -ScriptBlock {Start-Process "C:\sync\StorageSyncAgent_WS2016.msi" -ArgumentList "/q" -Wait} 

}

#2019
elseif

($testpath = Test-Path  'C:\sync\StorageSyncAgent_WS2019.msi')

{ write-host 'installing StorageSyncAgent_WS2019.msi' -ForegroundColor Yellow 
Invoke-Command -ScriptBlock {Start-Process "C:\sync\StorageSyncAgent_WS2019.msi" -ArgumentList "/q" -Wait} 
}

else

{write-host 'Did not detect a storagesyncagent MSI!' -ForegroundColor Red}

Start-Sleep -s 5
#check installation of either
$testpath = Test-Path  'C:\Program Files\Azure'

if ($testpath -eq 'true')

{ write-host 'azure file sync installed' -ForegroundColor Green
}

else

{ write-host 'azure file sync FAILED to install' -ForegroundColor Red }

# 9 install certifiytheweb

choco install certifytheweb --force -y
$testpath = Test-Path  'C:\Program Files\CertifyTheWeb'
if ($testpath -eq 'true')

{ }

# 10 install Chrome

choco install googlechrome --force -y
$testpath = Test-Path  'C:\Program Files (x86)\Google\Chrome'
if ($testpath -eq 'true')

{ }

# 11 download SnagR dependencies and install in the right order
    #11.1 download accessdatabaseengine

$testpath = Test-Path  'C:\SnagRTemp'

if ($testpath -eq 'true')

{ write-host 'C:\SnagRTemp Directory already exists, skipping creation process' -ForegroundColor Red }

else

{ write-host 'Creating new directory and downloading files' -ForegroundColor Green
New-Item -ItemType directory -Path C:\SnagRTemp }




$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "AccessDatabaseEngine_x64.exe"
$TargetFolderPath = 'C:\SnagRTemp'
write-host 'Downloading' $Blob1Name -ForegroundColor yellow

$context = New-AzureStorageContext `
-StorageAccountName $StorageAccountName = "INSERTACCOUNTHERE" 
-StorageAccountKey $StorageAccountKey

$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath
write-host $Blob1Name 'downloaded to' $TargetFolderPath -ForegroundColor green

    #11.2 download ArialUnicodeMS.ttf
    $testpath = Test-Path  'C:\SnagRTemp'

if ($testpath -eq 'true')

{ write-host 'C:\SnagRTemp Directory already exists, skipping creation process' -ForegroundColor Red }

else

{ write-host 'Creating new directory and downloading files' -ForegroundColor Green
New-Item -ItemType directory -Path C:\SnagRTemp}




$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "ArialUnicodeMS.ttf"
$TargetFolderPath = 'C:\SnagRTemp'
write-host 'Downloading' $Blob1Name -ForegroundColor yellow

$context = New-AzureStorageContext `
-StorageAccountName $StorageAccountName = "INSERTACCOUNTHERE" 
-StorageAccountKey $StorageAccountKey

$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath

$testpath = Test-Path  'C:\SnagRTemp\ArialUnicodeMS.ttf'

if ($testpath -eq 'true')

{ write-host $Blob1Name 'downloaded to' $TargetFolderPath -ForegroundColor green 
}

else

{ write-host $Blob1Name 'FAILED to download to' $TargetFolderPath -ForegroundColor Red
}





    #11.3 download SharedManagementObjects.msi

    $testpath = Test-Path  'C:\SnagRTemp'

if ($testpath -eq 'true')

{ write-host 'C:\SnagRTemp Directory already exists, skipping creation process' -ForegroundColor Red }

else

{ write-host 'Creating new directory and downloading files' -ForegroundColor Green
New-Item -ItemType directory -Path C:\SnagRTemp }




$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "SharedManagementObjects.msi"
$TargetFolderPath = 'C:\SnagRTemp'
write-host 'Downloading' $Blob1Name -ForegroundColor yellow

$context = New-AzureStorageContext `
-StorageAccountName $StorageAccountName = "INSERTACCOUNTHERE" 
-StorageAccountKey $StorageAccountKey

$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath
write-host $Blob1Name 'downloaded to' $TargetFolderPath -ForegroundColor green


    #11.4 download SQLSysClrTypes.msi


    $testpath = Test-Path  'C:\SnagRTemp'

if ($testpath -eq 'true')

{ write-host 'C:\SnagRTemp Directory already exists, skipping creation process' -ForegroundColor Red }

else

{ write-host 'Creating new directory and downloading files' -ForegroundColor Green
New-Item -ItemType directory -Path C:\SnagRTemp }




$StorageAccountName = "INSERTACCOUNTHERE" 
$StorageAccountKey = "INSERTKEYHERE"
$ContainerName = "sync"
$Blob1Name = "SQLSysClrTypes.msi"
$TargetFolderPath = 'C:\SnagRTemp'
write-host 'Downloading' $Blob1Name -ForegroundColor yellow

$context = New-AzureStorageContext `
-StorageAccountName $StorageAccountName = "INSERTACCOUNTHERE" 
-StorageAccountKey $StorageAccountKey

$result = Get-AzureStorageBlobContent `
-Blob $Blob1Name `
-Container $ContainerName `
-Context $context `
-Destination $TargetFolderPath
write-host $Blob1Name 'downloaded to' $TargetFolderPath -ForegroundColor green

# #############################
#11.5 installation of downloaded files
#e#################
write-host 'installing database engine' -ForegroundColor Yellow



   Invoke-Command -ScriptBlock {Start-Process "C:\SnagRTemp\AccessDatabaseEngine_x64.exe" -ArgumentList "/q" -Wait} 
   start-sleep -seconds 15

$testpath = Test-Path  'C:\Program Files\Microsoft Office'

if ($testpath -eq 'true')

{ write-host 'AccessDatabaseEngine_x64 installed succesfuly' -ForegroundColor Green 

}

else

{ write-host 'Failed to install AccessDatabaseEngine_x64' -ForegroundColor Red
New-Item -ItemType directory -Path C:\SnagRTemp }

#font 
write-host 'Installing Font' -ForegroundColor Yellow


$SourceDir   = "C:\SnagRTemp\"
$Source      = "C:\windows\Fonts*"
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$TempFolder  = "C:\Windows\Temp\Fonts"

# Create the source directory if it doesn't already exist
New-Item -ItemType Directory -Force -Path $SourceDir

New-Item $TempFolder -Type Directory -Force | Out-Null

Get-ChildItem -Path $Source -Include '*.ttf','*.ttc','*.otf' -Recurse | ForEach {
    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {

        $Font = "$TempFolder\$($_.Name)"
        
        # Copy font to local temporary folder
        Copy-Item $($_.FullName) -Destination $TempFolder
        
        # Install font
        $Destination.CopyHere($Font,0x10)
        
        write-host 'installed Font' -ForegroundColor Green

        # Delete temporary copy of font
        Remove-Item $Font -Force
    }
}



#SQLSysClrTypes

write-host 'Installing SQL server 2016 CLR type' -ForegroundColor Yellow
Invoke-Command -ScriptBlock {Start-Process  "C:\SnagRTemp\SQLSysClrTypes.msi" -ArgumentList "/q" -Wait} 
$testpath = Test-Path  'C:\Program Files\Microsoft SQL Server'
if ($testpath -eq 'true')

{ write-host 'SQLSysClrTypes installed succesfuly' -ForegroundColor Green
}

else

{ write-host 'Failed to install SQLSysClrTypes' -ForegroundColor Red
New-Item -ItemType directory -Path C:\SnagRTemp }

Start-Sleep -s 5

#SharedManagementObjects


write-host 'Installing SharedManagementObjects' -ForegroundColor Yellow
Invoke-Command -ScriptBlock {Start-Process  "C:\SnagRTemp\SharedManagementObjects.msi" -ArgumentList "/q" -Wait} 
write-host 'SharedManagementObjects installed succesfuly' -ForegroundColor Green



#12 finished , conclusion , logic app etc

write-host 'Finished script' -ForegroundColor Green
#12.1 Check if anything failed

Write-Host '###########################################'
Write-Host '###########################################'
Write-Host '###########################################'
Write-Host '###########################################'
Write-Host 'Final Check:'

if ( (test-path -path "C:\Program Files\Notepad++")  -or (test-path "C:\Program Files (x86)\Notepad++")  )

{ write-host 'notepad ++ is installed'
$check1 = 'ok' }

else

{write-host 'notepad ++ not installed' -ForegroundColor red 
$check1 = 'fail'}

if ( (test-path -path "C:\Program Files\WinRAR")  -or (test-path "C:\Program Files (x86)\WinRAR")  )

{ write-host 'winrar is installed'
$check2 = 'ok' }

else

{write-host 'winrar not installed' -ForegroundColor red 
$check2 = 'fail'}

if ( (test-path -path "C:\Program Files\Microsoft Visual Studio")  -or (test-path "C:\Program Files (x86)\Microsoft Visual Studio")  )

{ write-host 'Visual studio is installed'
$check3 = 'ok' }

else

{write-host 'Visual studio not installed' -ForegroundColor red
$check3 = 'fail' }

if ( (test-path -path "C:\Program Files\TortoiseSVN")  -or (test-path "C:\Program Files (x86)\TortoiseSVN")  )

{ write-host 'TortoiseSVN is installed'
$check4 = 'ok' }

else

{write-host 'TortoiseSVN not installed' -ForegroundColor red
$check4 = 'fail' }

if ( (test-path -path "C:\Program Files\Azure")  -or (test-path "C:\Program Files (x86)\Azure")  )

{ write-host 'Azure file sync is installed'
$check5 = 'ok' }

else

{write-host 'Azure file sync not installed' -ForegroundColor red
$check5 = 'fail' }

if ( (test-path -path "C:\Program Files\CertifyTheWeb")  -or (test-path "C:\Program Files (x86)\CertifyTheWeb")  )

{ write-host 'CertifyTheWeb is installed'
$check6 = 'ok' }

else

{write-host 'CertifyTheWeb not installed' -ForegroundColor red
$check6 = 'fail' }

if ( (test-path -path "C:\Program Files\Google\Chrome'")  -or (test-path "C:\Program Files (x86)\Google\Chrome")  )

{ write-host 'Google Chrome  is installed'
$check7 = 'ok' }

else

{write-host 'Google Chrome not installed' -ForegroundColor red
$check7 = 'fail' }

if ( (test-path -path "C:\Program Files\Microsoft Office")  -or (test-path "C:\Program Files (x86)\Microsoft Office")  )

{ write-host 'AccessDatabaseEngine_x64 is installed'
$check8 = 'ok' }

else

{write-host 'AccessDatabaseEngine_x64 not installed' -ForegroundColor red
$check8 = 'fail' }


if ( (test-path -path "C:\Program Files\Microsoft SQL Server'")  -or (test-path "C:\Program Files (x86)\Microsoft SQL Server")  )

{ write-host 'Microsoft SQL Server is installed'
$check9= 'ok' }

else

{write-host 'Microsoft SQL Server installed' }


#12.2 Send report to logicapp to inform the folks back home

$array = $check1,
$check2,
$check3,
$check4,
$check5,
$check6,
$check7,
$check8,
$check9

write-host $array

if ($array -contains 'fail')

{write-host 'Failure detected'
write-host 'Total or partial failure...opening logfile'
Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Status':'failure'}"
Start-Process notepad -FilePath "c:/PSLog/$logdate.txt"
}

else

{ write-host 'All installed succesfuly' -ForegroundColor Green -BackgroundColor white
Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Status':'success'}"
}

#deletion / cleanup
Remove-Item -LiteralPath "C:\SnagRTemp" -Force -Recurse
Remove-Item -LiteralPath "C:\sync" -Force -Recurse
Remove-Item -LiteralPath "C:\nuget.exe" -Force -Recurse

Stop-Transcript 
