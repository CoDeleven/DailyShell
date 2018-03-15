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
        $cookie.Value = $global:loldirectory
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
    }
    
}

Function queryPlayerGameId($playerName){
    $pattern = "\$.OP.GG.matches.openSpectate\((\d*?)\)"
    $url = "http://www.op.gg/summoner/spectator/userName={userName}&".Replace("{userName}", $playerName)
    $response = Invoke-WebRequest -Uri $url
    $null = $response -match $pattern
    $gameId = $Matches[1]
    if($gameId){
        writeHostInColor -message 'Player',$playerName,'Is Playing' -color Green
        downloadReplayBat($gameId)
    }
}

Function startPolling($playerList){
    #while($true){
        for($i = 0; $i -lt $playerList.Count; $i++){
            $playerName = $playerList[$i];
            $result = checkPlayingStatus($playerName)
            if($result -eq 1){
                queryPlayerGameId($playerName)
            }
        }
        writeHostInColor -message 'No Players Are Playing' -color Red
        #Start-Sleep –s $global:interval
    #}
}
# hide the scroll bar
$ProgressPreference='silentlycontinue'

# 请在这里设置要订阅得选手账号 "选手账号" ， 请用 英文下得逗号"," 分割
$global:subscribePlayerList = "wlstla2", "The shy"
# 请在这里设置你LOL得目录，包含RADS文件夹得目录，替换双引号里面得内容即可
$global:loldirectory = "F:\League of Legends"
# 多久查询一遍，间隔过短会占用CPU
$global:interval = 10

Write-Host "欢迎使用OPMM V0.1"
Write-Host "当前订阅账号：" $global:subscribePlayerList
write-host "当前LOL目录：" $global:loldirectory
#Write-Host "查询间隔：" $global:interval
Write-Host "如果您有任何问题或建议请您及时和我联系：codelevex@gmail.com"
startPolling -playerList $subscribePlayerList