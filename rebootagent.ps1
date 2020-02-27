cls
$event = (get-winevent system  | where {$_.LevelDisplayName -eq "Critical"} |  select-object -first 1)
 $event.TimeCreated |out-file -FilePath 'C:\powershell\event.txt' -Force

 $events = $username = Get-Content 'C:\powershell\event.txt'


 $replace1 = (get-winevent system  | where {$_.LevelDisplayName -eq "Critical"} |  select-object -first 5)
 $replace1.TimeCreated |out-file -FilePath 'C:\powershell\replace.txt' -Force

 $replace2 = Get-Content 'C:\powershell\replace.txt'

 write-host $events

 [uint16]$count =  Get-Content C:\powershell\healthcheck.txt
 $count.ToInt32($null)
 write-host $count
 $count = $count + 1 | out-file -FilePath 'C:\powershell\healthcheck.txt' -Force



Invoke-WebRequest -UseBasicParsing 'URL' -ContentType "application/json" -Method POST -Body "{ 'Name':'$env:computername', 'Log':'$events'}"

#if crash occured 10 times within a week

 [uint16]$count =  Get-Content C:\powershell\healthcheck.txt
 $count.ToInt32($null)

if ($count -gt 10)
{
Invoke-WebRequest -UseBasicParsing 'URL' -ContentType "application/json" -Method POST -Body "{ 'Name':'$env:computername', 'Log':'$replace2'}"

}
