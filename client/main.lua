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
					OpenMenu()

					-- Wait for menu control
					while ESX.UI.Menu.IsOpen("default", GetCurrentResourceName(), "general_menu") do
						Wait(50)
					end
                end
            end
        end
	end
end)

function OpenMenu()
	ESX.UI.Menu.CloseAll()

	local options = {
		{label = "Buy 1 Lottery Ticket ($" .. Config.TicketCost * 1 .. ")", value = 'buy_one'},
		{label = "Buy 10 Lottery Tickets ($" .. Config.TicketCost * 10 .. ")", value = 'buy_ten'},
		{label = "Buy 100 Lottery Ticket ($" .. Config.TicketCost * 100 .. ")", value = 'buy_one_hundred'}
	}
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'general_menu', {
		title = "Casino Tokens",
		align = "center",
		elements = options
	}, function(data, menu)
		if data.current.value == "buy_one" then
			TriggerServerEvent('esx_Lottery:BuyLottery', 1)
		elseif data.current.value == "buy_ten" then
			TriggerServerEvent('esx_Lottery:BuyLottery', 10)
		elseif data.current.value == "buy_one_hundred" then
			TriggerServerEvent('esx_Lottery:BuyLottery', 100)
		end
	end,
	function(data, menu)
		menu.close()
	end)
end