
function Remove-SentinelOneGroup{
Param(
 [string]$apikey,
 [string]$groupid,
 [string]$instance
)



$uri = "https://$instance.sentinelone.net/web/api/v2.0/agents/actions/decommission"
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
        $Headers.Add('Authorization','APIToken '+$APIKey)

        # Build REST parameters
        $Params = @{}
        $Params.Add('Body', ($Body))
        $Params.Add('Method', 'POST')
        $Params.Add('Uri', $URI)
        $Params.Add('ErrorVariable', 'RESTError')
        $Params.Add('ContentType', 'application/json')
        $Params.Add('Headers', $Headers)


        $Result = Invoke-RestMethod @Params

        if($RESTError) {
            Write-Host $RESTError.message -ForegroundColor Red
        } else {
            $Result
        }

      }
