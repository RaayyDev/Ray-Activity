local firstSpawn = false

AddEventHandler('playerSpawned', function()
	if firstSpawn == false then
		TriggerServerEvent('Ray-Activity_connect', GetPlayerName(PlayerId()))
		firstSpawn = true
	end
end)
