function Restart-SentinelOneGroup {
  <#
  .SYNOPSIS
  Restarts all VM's in a Group with the SentinelOne agent
  
  .DESCRIPTION
  Restarts all assets in SentinelOne Group based on Group ID. This was used in a pipeline to clear any warnings related to deepvisibility
  
  .PARAMETER apikey
  API key provided in SentinelOne 
  
  .PARAMETER groupid
  Group ID listed in SentinelOne for the list of resources you would like to decomission
  
  .PARAMETER instance
  Instance name for your hosted SentinelOne Instance
  
  .EXAMPLE
  Remove-SentinelOneGroup -apikey "1231lkjaldkjfa1231" -groupid "12341232" -instance "usea123132"
  
  .NOTES
  General notes
  #>
  Param(
    [string]$apikey,
    [string]$groupid,
    [string]$instance
  )


  $uri = "https://$instance.sentinelone.net/web/api/v2.0/agents/actions/restart-machine"
  $body = @"

{
  "filter": {
    "isUninstalled": false,
    "groupIds": [
      "$groupid"
    ]
  }
}
"@

  # Request Headers
  $Headers = @{}
  $Headers.Add('Authorization', 'APIToken ' + $APIKey)

  # Build REST parameters
  $Params = @{}
  $Params.Add('Body', ($Body))
  $Params.Add('Method', 'POST')
  $Params.Add('Uri', $URI)
  $Params.Add('ErrorVariable', 'RESTError')
  $Params.Add('ContentType', 'application/json')
  $Params.Add('Headers', $Headers)


  $Result = Invoke-RestMethod @Params

  if ($RESTError) {
    Write-Host $RESTError.message -ForegroundColor Red
  }
  else {
    $Result
  }

}
