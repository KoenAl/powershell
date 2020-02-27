############################################################################################
#                                   Koen.                                                  #
############################################################################################
#v1 
#Script checks 200 http from list.


#Place URL list file in the below path
$endresult = 0
start-Transcript -Path "C:\results.txt" -Force
$URLListFile = "C:\iislist.txt"
$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue

write-host 'Starting 200 HTTP request status for websites listed...' -ForegroundColor Green  
start-sleep -s 2 
cls
#For every URL in the list
Foreach($Uri in $URLList) {
    try{
        #For proxy systems
        [System.Net.WebRequest]::DefaultWebProxy = [System.Net.WebRequest]::GetSystemWebProxy()
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        start-sleep -s 0.5
        [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

        #Web request
        $req = [system.Net.WebRequest]::Create($uri)
        $res = $req.GetResponse()
    }catch {
        #Err handling
        $res = $_.Exception.Response
    }
    $req = $null

    #Getting HTTP status code
    $int = [int]$res.StatusCode

    #Writing on the screen
    if
    ($int -eq 0)
    { 
        $endresult = $endresult + 1
        
        Write-Host "$int - $uri" -ForegroundColor Red


  
    }
    else
    {
        Write-Host "$int - $uri" -ForegroundColor green
    }

    #Disposing response if available
    if($res){
        $res.Dispose()
    }
}

#Report confirmation

write-host $endresult
if ($endresult -gt 0)
{
    write-host  $endresult 'total websites not returning 200' -ForegroundColor red  

}

else
{
    write-host  'All websites were returning a 200 HTTP request as expected' -ForegroundColor green  

}
write-host 'Do you want to make a print out?' -ForegroundColor Yellow  

$yesNo = Read-Host -Prompt 'Do you want to make a print out? Y/N: '

if ($yesno -eq 'y')

{
    write-host 'Output file to C:/result.txt' -ForegroundColor green 
    Stop-Transcript 
    stop-process -name *powershell*
}

else {
    Stop-Transcript
    write-host 'Exiting' -ForegroundColor Yellow 
    Remove-Item C:\results.txt -force
    stop-process -name *powershell*
    exit
    
}

exit
