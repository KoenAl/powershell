$testpath = Test-Path  'C:\DEVELOPMENT'
$testpath2 = Test-Path  'D:\DEVELOPMENT'

if ($testpath -eq 'true')

{ write-host 'Company Development detected on C:\ drive... Scanning for 3.5 Companies' -ForegroundColor Green
#3.5
Get-ChildItem 'C:\DEVELOPMENT\CompanyWeb3.5\Config\*'|
  ? { $_.PSIsContainer } |
  Measure-Object |
  select -Expand Count 
  write-host  '3.5 Companies' 
  write-host  '*************************'

#3.91
  Get-ChildItem 'C:\DEVELOPMENT\CompanyWeb3.91\Config\*'|
  ? { $_.PSIsContainer } |
  Measure-Object |
  select -Expand Count 
  write-host  '3.91 Companies'

} 



Elseif  ($testpath2 -eq 'true')

{ write-host 'Company Development detected on D:\ drive... Scanning for 3.5 Companies' -ForegroundColor Green
#3.5
Get-ChildItem 'D:\DEVELOPMENT\CompanyWeb3.5\Config\*'|
  ? { $_.PSIsContainer } |
  Measure-Object |
  select -Expand Count 
  write-host  '3.5 Companies' 
  write-host  '*************************'

#3.91
  Get-ChildItem 'D:\DEVELOPMENT\CompanyWeb3.91\Config\*'|
  ? { $_.PSIsContainer } |
  Measure-Object |
  select -Expand Count 
  write-host  '3.91 Companies'

} 



else {
    write-host 'Could not find Company installation folder' -ForegroundColor Red
}

