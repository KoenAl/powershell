$check = $true

while ($check -eq $true) {

$idle_time = [PInvoke.Win32.UserInput]::IdleTime

write-host $idle_time.Minutes

if ($idle_time.Minutes -ge '1') {$check = $false}
start-sleep -seconds 5
}
elseif (check = $false)

{




$sh = New-Object -ComObject "Wscript.Shell"
$intButton = $sh.Popup("Inactivity detected! No user input for 5 minutes! Press OK to avoid logout",15,"SnagR Monitoring Agent",0+64)
write-host $intButton
  switch  ($intButton) {

  '-1' {

  ## Negative feedback


  write-host 'no user input detected' -foregroundcolor red

  }

  '1' {

  ## Positive feedback

    write-host 'user input detected' -foregroundcolor green

  }

 

  }

  } 
