Function writeHostInColor([System.Object]$message, [System.ConsoleColor]$color){
    write-host -ForegroundColor $color -Object $message
}
Function encapsulate(){
    if(-not $Global:session){
        $Global:session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $cookieContainer = New-Object System.Net.CookieContainer
        $session.Cookies = $cookieContainer
        # create cooke for inject loldirectory automatically
        $cookie = New-Object system.Net.Cookie
        $cookie.Name = 'loldirectory'
        $cookie.Value = $global:config.loldirectory
        $cookie.Domain = 'www.op.gg'
        $cookie.Path = '/'
        # add the cookie to container
        $cookieContainer.Add($cookie)
    }
    
    return $Global:session
}
Function checkPlayingStatus($playerName){
    # create the json body
    $jsonObj = "{`"summonerName`": `"PLAYER_NAME`"}".Replace("PLAYER_NAME", $playerName)
    
    # to check playing status
    $response = Invoke-WebRequest -Uri http://www.op.gg/summoner/ajax/spectateStatus/ -Method POST -Body $jsonObj -ContentType application/json
    # convert responseJson to JsonObject
    $responseResult = ConvertFrom-Json -InputObject $response
    # checkStatus
    $playerStatus = select -InputObject $responseResult -property status
    if($playerStatus.status){
        return 1
    }else{
        return -1
    }
}

Function downloadReplayBat($gameId){
    $private:session = encapsulate
    # call function encapsulate when invoke-webrequest
    $Private:response = Invoke-WebRequest -UseBasicParsing -WebSession $private:session -Uri http://www.op.gg/match/new/batch/id=$gameId
    
    if($Private:response.statusCode -eq 200){
        $Private:filename = $Private:response.Headers.item("Content-Disposition").split("`"")[1]
        $Private:content = [System.Text.Encoding]::UTF8.GetString($Private:response.Content)
        Out-File -FilePath ~\Desktop\$Private:filename -Encoding utf8 -InputObject $Private:content
        Start-Process ~\Desktop\$Private:filename -Wait
    }
    
}

Function queryPlayerGameId($playerName){
    $pattern = "\$.OP.GG.matches.openSpectate\((\d*?)\)"
    $url = "http://www.op.gg/summoner/spectator/userName={userName}&".Replace("{userName}", $playerName)
    $response = Invoke-WebRequest -Uri $url
    $null = $response -match $pattern
    $gameId = $Matches[1]
    if($gameId){
        downloadReplayBat($gameId)
    }
}

Function startPolling($playerList){
    while($true){
        for($i = 0; $i -lt $playerList.Count; $i++){
            $playerName = $playerList[$i];
            $result = checkPlayingStatus($playerName)
            if($result -eq 1){
                writeHostInColor -message $playerName,'正在游戏...' -color Green
                queryPlayerGameId($playerName)
            }else{
                writeHostInColor -message $playerName,'不在游戏...' -color RED
            }
        }
        Start-Sleep –s $global:config.interval
    }
}
# hide the scroll bar
$ProgressPreference='silentlycontinue'

Function initConfig(){
    # get the config from current directory
    # | ConvertFrom-Json
    $private:configJson = Get-Content -Path '.\opmm.json'
    # handle the escape character
    $private:configJson = $private:configJson -replace '\\','/'
    
    Write-Host $private:configJson
    $global:config = $private:configJson | ConvertFrom-Json
}
# init the config
initConfig

Write-Host "欢迎使用OPMM V0.2"
Write-Host "当前订阅账号：" $global:config.subscribePlayerList
write-host "当前LOL目录：" $global:config.loldirectory
Write-Host "查询间隔：" $global:config.interval
Write-Host "如果您有任何问题或建议请您及时和我联系：codelevex@gmail.com"
startPolling -playerList $global:config.subscribePlayerList
