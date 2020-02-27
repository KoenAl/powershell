Connect-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "<Subscription_Name>"

$Headers=@{
    'authorization'="Bearer <bearer_token>"
}

# Get all resources and their changed time

$resources= Invoke-RestMethod -uri 'https://management.azure.com/subscriptions/<subscription_id>/resources?api-version=2018-05-01&$expand=changedTime,createdTime' -method get -Headers $Headers | select-object -Expandproperty value

# Delete all resources which have not been changed since 20 days

foreach ($resource in $resources)
{
$count=0
$time=[datetime]::Parse($resource.changedTime)
$datetime = (Get-Date).AddDays(-20)
$utcDatetime = $datetime.ToUniversalTime()            
if ($time -lt $utcDatetime)
{
$resource.id
$time
Write-Output "Deleting resource now"
Remove-AzureRmResource -ResourceId $resource.id
}
}
