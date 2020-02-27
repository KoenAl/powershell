$servers = get-content c:\powershell\rdpserver.txt
$trigger = $true
while ($trigger -eq $true)
{
foreach ($server in $servers){}
try
{ start-sleep -seconds 3
    $result = (New-Object System.Net.Sockets.TCPClient -ArgumentList $server ,3389) 
}
 catch

  {
     if($Error[0].Exception.Message.Contains("A connection attempt failed because the connected party did not properly respond after a period of time"))
     {
         write-host "There was an error establishing a connection!" -ForegroundColor Red
         write-host $Error[0].Exception.Message -ForegroundColor Yellow
         $errorpayload = ($Error[0].Exception.Message)
         Invoke-WebRequest -UseBasicParsing 'http://URL' -ContentType "application/json" -Method POST -Body "{ 'Error':'$errorpayload', 'Log':'$events'}"

     }
 }
 write-host "Succesfuly RDP connected to all servers!" -ForegroundColor green
 start-sleep -seconds 120
}
 
 
