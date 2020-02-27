#part of creating my own metric program to save costs. constantly sends performance metrics to the cloud which can then later be analyzed

$trigger1 = $true
while ($trigger1 = $true)
{

$CpuLoad = (Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average ).Average
$Ramload = (Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average ).average

$drive1 = get-psdrive c
$used_size = $drive1.used

$drive2 = get-psdrive c
$free_size = $drive2.free
$computer = $env:computername
$freespace = ($free_size / 1GB)
$usedspace = ($used_size / 1GB)
cls

write-host "Report for" $computer
write-host $cpuload '% CPU'
write-host $Ramload '% RAM'
write-host $freespace "GB"
write-host $usedspace "GB"


Invoke-WebRequest -UseBasicParsing 'LOGICAPPURL' -ContentType "application/json" -Method POST -Body "{ 'Name':'$computer', 'Free Space':'$freespace', 'Used Space':'$usedspace', 'RAM':'$Ramload', 'CPU':'$CpuLoad'}"

start-sleep -seconds 2

}
until ($trigger = $false) 
 
