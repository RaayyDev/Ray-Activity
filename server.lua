local playersData = {}
local playersDataLogged = {}
local playersDataActuall = {}


MySQL.ready(function()
    print('discord.gg/oui')
    MySQL.Async.fetchAll('SELECT * FROM activity', {}, function(result)	
        for i=1, #result, 1 do
            playersData[result[i].identifier] = result[i].time
            playersDataLogged[result[i].identifier] = result[i].login

		end
    end)
end)

function SecondsToClock(seconds)
    if seconds ~= nil then
        local seconds = tonumber(seconds)

        if seconds <= 0 then
            return "00:00:00";
        else
            hours = string.format("%02.f", math.floor(seconds/3600));
            mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
            secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
            return hours..":"..mins..":"..secs
        end
    end
end



function dropPlayer(source, reason)
    local identifier = GetPlayerIdentifiers(source)[1]
    local actualTime = os.time()
    local name = GetPlayerName(source)

    if playersData[identifier] ~= nil and playersDataActuall[identifier] ~= nil then
        local time = tonumber(actualTime - playersDataActuall[identifier])
        local timeFormatted = SecondsToClock(time)
        local totalTime = time + playersData[identifier]
        local totalTimeFormatted = SecondsToClock(totalTime)

        local lastLogoutTimestamp = os.date('%Y-%m-%d %H:%M:%S', actualTime)

        MySQL.Async.execute('UPDATE activity SET time = @time, last_logout = @last_logout WHERE identifier = @identifier',
            {['time'] = totalTime, ['last_logout'] = lastLogoutTimestamp, ['identifier'] = identifier},
            function(affectedRows)
                print('[Ray-Activity] Info updated on logout')
            end
        )

        playersData[identifier] = totalTime
    else
        print('^1[Ray-Activity] Error:^0 Can not save info player')
    end
end


AddEventHandler('playerDropped', function(reason)    
	dropPlayer(source, reason)
end)


RegisterNetEvent('Ray-Activity_connect')
AddEventHandler('Ray-Activity_connect', function(playerName)
	local _source = source	
    local _playerName = playerName
    local identifier = GetPlayerIdentifiers(_source)[1]
    local actuallTime = os.time()
    local ids = ExtractIdentifiers(source);
    local discord = ids.discord:gsub('discord:', '')
   
    if playersData[identifier] ~= nil then
        playersDataActuall[identifier] = actuallTime
        playersDataLogged[identifier] = playersDataLogged[identifier] + 1
        local totaltimeFormatted = SecondsToClock(playersData[identifier])
        MySQL.Async.execute('UPDATE activity SET login = login + 1 WHERE identifier = @identifier',
            {['identifier'] = identifier},
            function(affectedRows)
                print('^1[Ray-Activity] Info saved')
            end
        )
    else        
        playersDataActuall[identifier] = actuallTime
        playersData[identifier] = 0
        MySQL.Async.execute('INSERT INTO activity (identifier, time, login, discord) VALUES (@identifier, @time, @login, @discord)',
            { ['identifier'] = identifier, ['time'] = 0, ['login'] = 0, ['discord'] = discord},
            function(affectedRows)
                print('^1[Ray-Activity] Info saved')
            end
        )
    end
end)



function ExtractIdentifiers(source)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
end
    return identifiers
end
