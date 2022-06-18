Config = {}

-- COMMANDS SETTINGS --
Config.UseCommand = true -- If set to true, users can buy tickets using a command
Config.UsePosition = true -- If set to true, users can go to the preset location to buy a ticket

-- COMMAND SETTINGS --
Config.BuyCommand = 'buy-lottery'
Config.SeeTicketsCommand = 'see-tickets' -- This command will display how many tickets you have
Config.LotteryStatusCommand = 'lottery-status' -- See the current pot & winning size of the lottery

-- POSITION SETTINGS --
Config.PurchaseLocations = {
    vector3(25.746425628662, -1346.4639892578, 29.49702835083) -- 24/7 on Innocent Blvd
}

-- GENERAL LOTTERY SETTINGS --
Config.TicketCost = 100
Config.DrawInterval = 30 -- This is set in minutes
Config.DrawingMultiplier = 10 -- This is what the pot (purchased tickets amount) will be multiplied by for a total pot total (See below)
--[[
    For example, if 2 tickets have been bought, the pot would be $200. Then multiplied by the multipler would $2,000 for a total lottery winning
]]