local firstSpawn = false

AddEventHandler('playerSpawned', function()
	if firstSpawn == false then
		TriggerServerEvent('mrx_connection', GetPlayerName(PlayerId()))
		firstSpawn = true
	end
end)