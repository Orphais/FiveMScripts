function showNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

RegisterCommand("mark", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    local hasVehicle = false

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
                        if hasVehicle == false then
                            local vehicleList = GetAllVehicleModels()
                            local hashModel = GetHashKey(vehicleList[math.random(1, #vehicleList)])
                            RequestModel(hashModel)
                            while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
                            local car = CreateVehicle(hashModel, posPed, 90, true, false)
                            TaskWarpPedIntoVehicle(ped, car, -1)
                            showNotification("Votre voiture a spawn.")
                            hasVehicle = true
                        else
                            hasVehicle = false
                            local lastVehicle = GetVehiclePedIsIn(ped, false) 
                            DeleteVehicle(lastVehicle)

                            local vehicleList = GetAllVehicleModels()
                            local hashModel = GetHashKey(vehicleList[math.random(1, #vehicleList)])
                            RequestModel(hashModel)
                            while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
                            local car = CreateVehicle(hashModel, posPed, 90, true, false)
                            TaskWarpPedIntoVehicle(ped, car, -1)
                            showNotification("Votre voiture a été modifié.")
                            hasVehicle = true
                        end
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