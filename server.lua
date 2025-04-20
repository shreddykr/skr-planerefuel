local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('plane-refuel:server:canPay', function(source, cb, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveMoney('cash', amount) then
        cb(true)
    else
        cb(false)
    end
end)
