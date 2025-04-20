local QBCore = exports['qb-core']:GetCoreObject()
local lastRefuelTime = 0 -- Track the last refuel time for refueling
local isRefueling = false -- Flag to check if refueling is in progress
local hasNotified = false -- Flag to check if the player has already been notified
local lastNotificationTime = 0 -- Track last notification time
local notificationCooldown = 10000 -- 10 seconds cooldown before sending the notification again
local inZone = false -- Track if the player is inside the refuel zone
local refuelCooldown = 0 -- Time in milliseconds when the next refuel is allowed

CreateThread(function()
    while true do
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local inAircraft = IsPedInAnyPlane(player) or IsPedInAnyHeli(player)
        local sleep = 1500

        if inAircraft then
            for _, zone in pairs(Config.RefuelZones) do
                local distanceToZone = #(coords - zone.coords)

                -- Blue circle visibiltty
                if distanceToZone < 50.0 then
                    sleep = 0
                    -- Draw the marker continuously (even after an error)
                    DrawMarker(1, zone.coords.x, zone.coords.y, zone.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 6.0, 6.0, 1.0, 0, 0, 255, 200, false, true, 2, false, nil, nil, false)

                    -- Show interaction prompt within 10 units
                    if distanceToZone < 10.0 then
                        -- Check if the cooldown time has passed before notifying again
                        if (GetGameTimer() - lastNotificationTime) > notificationCooldown then
                            -- If not notified yet and player is inside the zone, show the notification
                            if not hasNotified then
                                exports.ox_lib:notify({
                                    title = "Fuel Pump",
                                    description = "[E] Refuel Aircraft ($" .. Config.RefuelCost .. ")",
                                    position = "top-right",
                                    type = "info"
                                })
                                hasNotified = true -- Mark as notified to prevent further notifications
                                inZone = true -- Mark that the player is inside the zone
                                lastNotificationTime = GetGameTimer() -- Record the time of the notification
                            end
                        end

                        -- Handle the refuel interaction when pressing 'E'
                        if IsControlJustReleased(0, 38) then -- E key
                            local veh = GetVehiclePedIsIn(player, false)
                            local currentFuel = GetVehicleFuelLevel(veh)

                            -- Check if the fuel is already at or above 90%
                            if currentFuel >= 90.0 then
                                QBCore.Functions.Notify("Your aircraft is already full of fuel!", "error")
                                -- Reset notification flag and keep the player in the zone
                                hasNotified = false
                                inZone = true
                                -- Do not exit the function, continue the loop
                            else
                                -- Check if the cooldown has expired
                                if GetGameTimer() < refuelCooldown then
                                    local timeRemaining = math.floor((refuelCooldown - GetGameTimer()) / 1000) -- Get the remaining cooldown time in seconds
                                    QBCore.Functions.Notify("Please wait " .. timeRemaining .. " seconds before refueling again.", "error")
                                    -- Reset notification flag and keep the player in the zone
                                    hasNotified = false
                                    inZone = true
                                    -- Do not exit the function, continue the loop
                                else
                                    -- Disable exit controls for 30 seconds and set refueling flag
                                    DisableControlAction(0, 75, true)  -- Disable exit action (F)
                                    DisableControlAction(0, 44, true)  -- Disable "enter/exit" vehicle control
                                    SetEntityInvincible(veh, true) -- Make vehicle invincible to prevent damage

                                    -- Display refuel progress message and show notification for 30 seconds
                                    QBCore.Functions.Notify("Refueling... Please wait", "inform", 15000)

                                    -- Begin the refuel process with a 30-second wait
                                    Citizen.Wait(15000)

                                    -- After 30 seconds, refuel the aircraft
                                    if Config.FuelScript == 'LegacyFuel' then
                                        exports['LegacyFuel']:SetFuel(veh, Config.RefuelAmount)
                                    elseif Config.FuelScript == 'cdn-fuel' then
                                        exports['cdn-fuel']:SetFuel(veh, Config.RefuelAmount)
                                    elseif Config.FuelScript == 'lc_fuel' then
                                        exports['lc_fuel']:SetFuel(veh, Config.RefuelAmount)
                                    else
                                        QBCore.Functions.Notify("Fuel script not configured properly!", "error")
                                        return
                                    end
                                    QBCore.Functions.Notify("Refueled to " .. Config.RefuelAmount .. "%.", "success")

                                    -- Set the refuel cooldown to 1 minute after a successful refuel
                                    refuelCooldown = GetGameTimer() + 60000 -- 1 minute cooldown
                                    -- Re-enable the ability to exit the vehicle
                                    EnableControlAction(0, 75, true)  -- Re-enable exit action (F)
                                    EnableControlAction(0, 44, true)  -- Re-enable "enter/exit" vehicle control
                                    SetEntityInvincible(veh, false) -- Make the vehicle vulnerable again
                                    lastRefuelTime = GetGameTimer() -- Update the last refuel time
                                end
                            end
                        end
                    end
                else
                    -- If the player leaves the zone, reset the notification flag
                    if inZone then
                        hasNotified = false -- Reset the notification flag when the player leaves the zone
                        inZone = false -- Reset zone flag
                    end
                end
            end
        end

        Wait(sleep)
    end
end)
