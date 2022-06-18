ESX = nil

-- ESX BASE --
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(250)
	end
end)

-- Create Markers
Citizen.CreateThread(function()
    while not NetworkIsSessionStarted() do -- Wait for the user to load
		Wait(500)
	end

	while true do
		Citizen.Wait(1)
        for k,v in pairs(Config.PurchaseLocations) do
            DrawMarker(25, v.x, v.y, v.z - 0.98, 
		    0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
        end
	end
end)

-- Check the distance from the markers
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do -- Wait for the user to load
		Wait(500)
	end

	while true do
		Citizen.Wait(1)
        for k,v in pairs(Config.PurchaseLocations) do
            while #(GetEntityCoords(PlayerPedId()) - v) <= 1.0 do
                Citizen.Wait(0) -- REQUIRED
    
                -- Draw text with instructions
                ESX.Game.Utils.DrawText3D(v, "Press ~b~[E]~s~ to buy lottery tickets")
    
                -- Check for button press
                if IsControlJustReleased(0, 51) then
                    -- Do something
                end
            end
        end
	end
end)
