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
        #Start-Sleep �Cs $global:interval
    #}
}
# hide the scroll bar
$ProgressPreference='silentlycontinue'

# ������������Ҫ���ĵ�ѡ���˺� "ѡ���˺�" �� ���� Ӣ���µö���"," �ָ�
$global:subscribePlayerList = "wlstla2", "The shy"
# ��������������LOL��Ŀ¼������RADS�ļ��е�Ŀ¼���滻˫������������ݼ���
$global:loldirectory = "F:\League of Legends"
# ��ò�ѯһ�飬������̻�ռ��CPU
$global:interval = 10

Write-Host "��ӭʹ��OPMM V0.1"
Write-Host "��ǰ�����˺ţ�" $global:subscribePlayerList
write-host "��ǰLOLĿ¼��" $global:loldirectory
#Write-Host "��ѯ�����" $global:interval
Write-Host "��������κ��������������ʱ������ϵ��codelevex@gmail.com"
startPolling -playerList $subscribePlayerList