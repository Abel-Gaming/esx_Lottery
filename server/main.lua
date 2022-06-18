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
        if #boughtTickets >= 1 then
            DrawLottery()
        else
            TriggerClientEvent("chat:addMessage", -1, {
                color = {255, 255, 255},
                multiline = true,
                args = { '^1LOTTERY', "The lottery was not drawn because no tickets were purchased!" }
            })
        end
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

        if hasTicket(xPlayerIdentifier) then
            xPlayer.showNotification('You have ' .. xPlayerTickets .. ' lottery tickets')
        else
            xPlayer.showNotification('You do not have any lottery tickets!')
        end
    end, false)

    TriggerClientEvent('chat:addSuggestion', -1, Config.BuyCommand, 'Purchase Lottery Ticket', {
        { name="Tickets", help="Number of tickets to purchase" }
    })
end

RegisterCommand('drawLottery', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == 'admin' then
        if #boughtTickets >= 1 then
            DrawLottery()
        else
            xPlayer.showNotification('No lottery tickets have been purchased')
        end
    else
        xPlayer.showNotification('[ERROR] You are not an admin!')
    end
end, false)

function BuyTicket(source, tickets)
    -- Get the player information
    local xPlayer = ESX.GetPlayerFromId(source)
    local xPlayerName = xPlayer.getName()
    local xPlayerIdentifier = xPlayer.getIdentifier()
    local xPlayerMoney = xPlayer.getMoney()
    local totalAmount = tickets * Config.TicketCost

    if xPlayerMoney >= totalAmount then
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

            -- Take Money
            xPlayer.removeMoney(totalAmount)
    
            -- Increase pot
            lotteryPot = lotteryPot + totalAmount
        else
            if hasTicket(xPlayerIdentifier) then
                if addTickets(xPlayerIdentifier, tickets) then
                    -- Show notification
                    xPlayer.showNotification('You have purchased ' .. tickets .. ' more lottery ticket(s)')

                    -- Take Money
                    xPlayer.removeMoney(totalAmount)
    
                    -- Increase pot
                    lotteryPot = lotteryPot + totalAmount
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

                -- Take Money
                xPlayer.removeMoney(totalAmount)
    
                -- Increase pot
                lotteryPot = lotteryPot + totalAmount
            end
        end
    else 
        xPlayer.showNotification('You do not have enough money to purchase a lottery ticket')
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
    -- Show drawing lottery message
    TriggerClientEvent("chat:addMessage", -1, {
        color = {255, 255, 255},
        multiline = true,
        args = { '^1LOTTERY', "The lottery will be drawn in ^25 seconds!" }
    })

    -- Wait
    Wait(5 * 1000)

    -- Select winner and get details
    local lotteryWinner = boughtTickets[math.random(#boughtTickets)]
    local lotteryWinnerName = lotteryWinner.name
    local lotteryWinnerIdentifier = lotteryWinner.identifier
    local xPlayer = ESX.GetPlayerFromIdentifier(lotteryWinnerIdentifier)

    if xPlayer then
        -- Add the money
        xPlayer.addMoney(lotteryPot * Config.DrawingMultiplier)

        -- Notify the player
        xPlayer.showNotification('Congratulations! You have won the lottery of $' .. format_thousand(lotteryPot * Config.DrawingMultiplier))

        -- Notify chat
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 255, 255},
            multiline = true,
            args = { '^1LOTTERY', "The lottery has been won by ^4" .. lotteryWinnerName .. "^7!" }
        })

        -- Reset the lottery
        for k,v in pairs(boughtTickets) do 
            boughtTickets[k]=nil
        end
        lotteryPot = 0
    else
        -- Notify chat that the winner was not on and the winner will be redrawn
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 255, 255},
            multiline = true,
            args = { '^1LOTTERY', "The lottery has been won by an offline player!" }
        })
    end
end

function format_thousand(v)
    local s = string.format("%d", math.floor(v))
    local pos = string.len(s) % 3
    if pos == 0 then pos = 3 end
    return string.sub(s, 1, pos)
    .. string.gsub(string.sub(s, pos+1), "(...)", ",%1")
end