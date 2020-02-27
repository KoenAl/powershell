  $computer = $env:computername
  Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Name':'$computer'}"
 
$freespacethreshold = 20

# Setting path to servers.txt file for input later on...
$inputfilepath =  "C:\powershell"
$inputfilename = "servers.txt"
$workingfile = $inputfilepath + "\" + $inputfilename

#does the file exist?
$fileexist = test-path $workingfile

if ($? -eq $false)
{
  Write-Host "$inputfilename does not exist on $infputfilepath" -ForegroundColor Red -BackgroundColor Black
  Write-Host "Please Create the file with one server per line that you want checked" -ForegroundColor Red -BackgroundColor Black
  exit 1
}

#read the file into a variable for later processing
$servers = Get-Content $workingfile

# Step 1 this is to check the disk space and alert if their is 10% or less free
foreach ($s in $servers)
{
 $logicaldisks = Get-WmiObject -ComputerName $s Win32_Logicaldisk
 
 Foreach ($l in $logicaldisks)
 {
  $totalsize = $l.size
  $freespace = $l.freespace
  if ($freespace -gt 90)
  {
   $percentagefree = ($freespace / $totalsize ) * 100
   Write-Host $l.deviceid " has " $percentagefree "% free" 
     
   if ($percentagefree -lt $freespacethreshold)
   {
    Write-Host "Health Alert!" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Drive " $l.deviceid " has less the $freespacethreshold % free"
    Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Name':'$computer'}"
   } 
 }
 }
} 
