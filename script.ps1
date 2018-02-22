#check if the agent has been downloaded
$listener = ".\bin\Agent.Listener.exe"

If (Test-Path $listener) {

  .\bin\Agent.Listener.exe run

}Else{

  #download the agent
  $user = "user"
  $token = $env:VSTS_TOKEN
  $pair = "${user}:${token}"
  $bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
  $base64 = [System.Convert]::ToBase64String($bytes)
  $basicAuthValue = "Basic $base64"
  $headers = @{Accept="application/json;api-version=3.0-preview"; `
               Host="dotnetinnovations.visualstudio.com"; `
               Authorization=${basicAuthValue}}
  $content = (Invoke-WebRequest -Uri "https://dotnetinnovations.visualstudio.com/_apis/distributedtask/packages/agent?platform=win-x64" `
                                -Headers $headers `
                                -UseBasicParsing | ConvertFrom-Json)
  $download = $content.value.downloadurl[0]

  #retry if the download fails
  $downloadsuccess = $false
  [int]$retries = "0"
  do {
    try {
      wget -Uri $download -OutFile vsts-agent.zip
      $downloadsuccess = $true
    }
    catch {
      if ($retries -gt 10){
        Write-Host "Could not download the agent. Exiting..."
        exit
      }
      else {
        $retries = $retries + 1
      }
    }
  }
  While ($downloadsuccess -eq $false)

  #install and configure the agent
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory(".\vsts-agent.zip", ".\")

  $env:VSO_AGENT_IGNORE="VSTS_AGENT_URL,VSO_AGENT_IGNORE,VSTS_AGENT,VSTS_ACCOUNT,VSTS_TOKEN,VSTS_POOL,VSTS_WORK"
  if ($env:VSTS_AGENT_IGNORE -ne $null)
  {
      $env:VSO_AGENT_IGNORE="$env:VSO_AGENT_IGNORE,$env:VSTS_AGENT_IGNORE,VSTS_AGENT_IGNORE"
  }

  $env:VSTS_AGENT = $env:COMPUTERNAME
  $env:VSTS_WORK = "_work"
  $env:VSTS_POOL = "Default"

  & .\bin\Agent.Listener.exe configure --unattended `
      --agent "$env:VSTS_AGENT" `
      --url "https://$env:VSTS_ACCOUNT.visualstudio.com" `
      --auth PAT `
      --token "$env:VSTS_TOKEN" `
      --pool "$env:VSTS_POOL" `
      --work "$env:VSTS_WORK" `
      --replace

  #run the agent
  & .\bin\Agent.Listener.exe run

}
