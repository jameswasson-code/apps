function Add-LogicMonitorSDT {
<#
.SYNOPSIS
Adds an immediate Scheduled Down Time window to a Device Group based on the Group ID

.DESCRIPTION
Adds an immediate Scheduled Down Time window to a Device Group based on the Group ID and allows Maintenance Length in minutes

.PARAMETER AccessId
ID provided by LogicMonitor for API Access

.PARAMETER AccessKey
Access Key provided by LogicMonitor for API Access

.PARAMETER Company
Company Name listed in the instance URL. EX: contoso.logicmonitor.com

.PARAMETER DeviceGroupID
Device Group ID listed in LogicMonitor for the group being placed in SDT

.PARAMETER Maintenancelength
The number of minutes the device group should be in SDT. Example: 60 . Default Maintenance Length is 120.

.EXAMPLE
Add-LogicMonitorSDT -accessid "123lajjkfjdjd" -accesskey "thisisakey" -company "contoso" -devicegroupid "40" -maintenancelength "90"

.NOTES
General notes
#>
  Param(
    [string]$AccessId,
    [string]$AccessKey,
    [string]$Company,
    [string]$DeviceGroupID,
    [int]$Maintenancelength
  )



  <# Use TLS 1.2 #>
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


  # stdTYpe (integer)
  # 1 - one time, 2 - Weekly SDT, 3 - Monthly SDT, 4 - Daily SDT
  # we have to use "one time" style values because LM has no concept of day of month
  $stdTYpe = 1

  # type (string)
  # ServiceGroupSDT, DeviceGroupSDT, CollectorSDT
  $type = "DeviceGroupSDT"

  # dataSourceId (integer)
  # 0 = ALL
  $dataSourceId = 0

  <# request details #>
  $httpVerb = 'POST'
  $resourcePath = '/sdt/sdts'

  # maintenance start
  $maintenancestart = get-date -UFormat "%m/%d/%Y %H:%M:%S"

  #maintenance length (in minutes) Default is 120 minutes.
  if (!($Maintenancelength)) {
    $Maintenancelength = '120'
  }

  $startDate = (Get-Date -Date $maintenancestart).ToUniversalTime()
  $startDateepoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end $startDate).TotalMilliseconds)

  $endDate = $startDate.AddMinutes($Maintenancelength)
  $endDateepoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end $endDate).TotalMilliseconds)

  # device group data
  $data = '{"sdtType":' + $stdTYpe + ',"type":"' + $type + '","deviceGroupId":' + $DeviceGroupID + ',"dataSourceId":' + $dataSourceId + ',"startDateTime":' + $startDateepoch + ',"endDateTime":' + $endDateepoch + '}'

  <# Construct URL #>
  $url = 'https://' + $company + '.logicmonitor.com/santaba/rest' + $resourcePath

  <# Get current time in milliseconds #>
  $epoch = [Math]::Round((New-TimeSpan -start (Get-Date -Date "1/1/1970") -end (Get-Date).ToUniversalTime()).TotalMilliseconds)

  <# Concatenate Request Details #>
  $requestVars = $httpVerb + $epoch + $data + $resourcePath

  <# Construct Signature #>
  $hmac = New-Object System.Security.Cryptography.HMACSHA256
  $hmac.Key = [Text.Encoding]::UTF8.GetBytes($accessKey)
  $signatureBytes = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($requestVars))
  $signatureHex = [System.BitConverter]::ToString($signatureBytes) -replace '-'
  $signature = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($signatureHex.ToLower()))

  <# Construct Headers #>
  $auth = 'LMv1 ' + $accessId + ':' + $signature + ':' + $epoch
  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Authorization", $auth)
  $headers.Add("Content-Type", 'application/json')

  <# Make Request #>
  $response = Invoke-RestMethod -Uri $url -Method $httpVerb -Body $data -Header $headers

  <# Print status and body of response #>
  $status = $response.status
  $body = $response.data | ConvertTo-Json -Depth 5

  # Write-Host "Query:$response"
  Write-Host "Status:$status"
  Write-Host "Response:$body"

}
