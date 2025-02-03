function showNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

RegisterCommand("mark", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    Citizen.CreateThread(function ()
        while true do
            local interval = 1
            local posPed = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(posPed, pos, true)
            
            if dist < 10 then
                interval = 1
                DrawMarker(36, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 170, 0, 1, 2, 0, nil, nil, 0)   
                if dist < 2 then
                    AddTextEntry("SPAWNCAR", "Appuyez sur ~INPUT_PICKUP~ pour faire spawn votre voiture.")
                    DisplayHelpTextThisFrame("SPAWNCAR", false)
                    if IsControlJustPressed(1, 38) then
                        local hashModel = GetHashKey('buffalo2')
                        RequestModel(hashModel)
                        while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
                        local car = CreateVehicle(hashModel, posPed, 90, true, false)
                        TaskWarpPedIntoVehicle(ped, car, -1)
                        showNotification("Votre voiture a spawn.")
                    end
                end
            else 
                interval = 200
            end
            Citizen.Wait(interval)
        end
    end)
    showNotification("Mark")
end, false)
