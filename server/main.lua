--- ESX RELATED ---
ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local lotteryPot = 0
local boughtTickets = {}

RegisterServerEvent('esx_Lottery:BuyLottery')
AddEventHandler('esx_Lottery:BuyLottery', function(tickets)
    BuyTicket(source, tickets)
end)

-- Lottery Thread --
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.DrawInterval * 60000)
        print('Drawing lottery...')
        DrawLottery()
    end
end)

if Config.UseCommand then
	RegisterCommand(Config.BuyCommand, function(source, args)
        local tickets = args[1]
		BuyTicket(source, tickets)
	end, false)

    RegisterCommand(Config.SeeTicketsCommand, function(source, args)
        local xPlayer = ESX.GetPlayerFromId(source)
        local xPlayerIdentifier = xPlayer.getIdentifier()
        local xPlayerTickets = checkTickets(xPlayerIdentifier)
        xPlayer.showNotification('You have ' .. xPlayerTickets .. ' lottery tickets')
    end, false)

    TriggerEvent('chat:addSuggestion', Config.BuyCommand, 'Purchase Lottery Ticket', {
        { name="Tickets", help="Number of tickets to purchase" }
    })
end

function BuyTicket(source, tickets)
    -- Get the player information
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()
    local xPlayerIdentifier = xPlayer.getIdentifier()

    if #boughtTickets == 0 then
        -- Insert the ticket purchase to the table of purchased tickets
        table.insert(boughtTickets,
            {
                name = xPlayerName, 
                identifier = xPlayerIdentifier, 
                tickets = tickets
            }
        )

        -- Show notification
        xPlayer.showNotification('You have purchased ' .. tickets .. ' lottery ticket(s)')
    else
        if hasTicket(xPlayerIdentifier) then
            if addTickets(xPlayerIdentifier, tickets) then
                xPlayer.showNotification('You have purchased ' .. tickets .. ' more lottery ticket(s)')
            else
                xPlayer.showNotification('There was an error purchasing ' .. tickets .. ' more lottery ticket(s)')
            end
        else
            -- Insert the ticket purchase to the table of purchased tickets
            table.insert(boughtTickets, 
                {
                    name = xPlayerName,
                    identifier = xPlayerIdentifier,
                    tickets = tickets
                }
            )
    
            -- Show notification
            xPlayer.showNotification('You have purchased ' .. tickets .. ' lottery ticket(s)')
        end
    end
end

function hasTicket(identifier)
    for index, value in pairs(boughtTickets) do
        if value.identifier == identifier then
            return true
        end
    end
    return false
end

function addTickets(identifier, tickets)
    for index, value in pairs(boughtTickets) do
        if value.identifier == identifier then
            value.tickets = value.tickets + tickets
            return true
        end
    end
    return false
end

function checkTickets(identifier)
    local xPlayer = ESX.GetPlayerFromId(player)
    for index, value in pairs(boughtTickets) do
        if value.identifier == identifier then
            local totalTickets = math.floor(value.tickets)
            return totalTickets
        end
    end
    return false
end

function DrawLottery()
    local lotteryWinner = boughtTickets[math.random(#boughtTickets)]
    local lotteryWinnerName = lotteryWinner.name
    local lotteryWinnerIdentifier = lotteryWinner.identifier
    local xPlayer = ESX.GetPlayerFromIdentifier(lotteryWinnerIdentifier)

    if xPlayer then
        -- Add the money
        xPlayer.addMoney(lotteryPot * Config.DrawingMultiplier)

        -- Notify the player
        xPlayer.showNotification('Congratulations! You have won the lottery of $' .. lotteryPot * Config.DrawingMultiplier)

        -- Notify chat
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 255},
            multiline = true,
            args = { 'LOTTERY', "The lottery has been won by " .. lotteryWinnerName .. "!" }
        })
    else
        -- Notify chat that the winner was not on and the winner will be redrawn
        TriggerEvent("chat:addMessage", {
            color = {255, 255, 255},
            multiline = true,
            args = { 'LOTTERY', "The lottery has been won by an offline player. It will redrawn in 30 seconds!" }
        })

        -- Wait
        Citizen.Wait(30 * 1000)

        -- Redraw Lottery
        DrawLottery()
    end
end