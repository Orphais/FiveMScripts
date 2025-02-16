function showNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

-- Menu
RMenu.Add('showcase', 'main', RageUI.CreateMenu("VEHICLE MENU", "Undefined for using SetSubtitle"))
RMenu:Get('showcase', 'main'):SetSubtitle("~b~CHOOSE YOUR CAR")
RMenu:Get('showcase', 'main').EnableMouse = false
RMenu:Get('showcase', 'main').Closed = function()
    -- TODO Perform action 
end;

local cars = GetAllVehicleModels()

RegisterCommand('delete-basic-rmenu', function()
    RMenu:Delete('showcase', 'main')
end, false)


--Mark
RegisterCommand("carmark", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    
    local hasVehicle = false

    Citizen.CreateThread(function ()
        while true do
            local interval = 1
            local posPed = GetEntityCoords(ped)
            local dist = GetDistanceBetweenCoords(posPed, pos, true)
            
            -- Etre à une distance < 10 pour voir le marqueur
            if dist < 10 then
                interval = 1
                DrawMarker(36, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 170, 0, 1, 2, 0, nil, nil, 0)   
                -- Etre à une distance < 2 pour interagir avec le marqueur
                if dist < 2 then
                    AddTextEntry("SPAWNCAR", "Appuyez sur ~INPUT_PICKUP~ pour faire spawn votre voiture.")
                    DisplayHelpTextThisFrame("SPAWNCAR", false)
                    
                    -- Spawn
                    if IsControlJustPressed(1, 38) then
                        RageUI.Visible(RMenu:Get('showcase', 'main'), not RageUI.Visible(RMenu:Get('showcase', 'main')))
                    end
                
                    if RageUI.Visible(RMenu:Get('showcase', 'main')) then
                        RageUI.DrawContent({ header = true, glare = true, instructionalButton = true }, function()
                            ---Items            
                            for i = 1, #cars do
                                local carname = GetDisplayNameFromVehicleModel(cars[i]) 
                                RageUI.Button(carname, "Faire apparaître un ".. carname, { }, true, function(Hovered, Active, Selected)
                                    if (Hovered) then
                    
                                    end
                                    if (Active) then
                    
                                    end
                                    if (Selected) then
                                        -- spawn car + tp
                
                                        local ped = PlayerPedId()
                                        local posPed = GetEntityCoords(ped)
                
                                        
                                        if IsPedInAnyVehicle(ped, true) then
                                            DeleteVehicle(GetVehiclePedIsIn(ped, false))
                                        end
                                        local hashModel = GetHashKey(cars[i])
                                        RequestModel(hashModel)
                                        while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
                                        
                                        local car = CreateVehicle(hashModel, posPed, 90, true, false)
                                        TaskWarpPedIntoVehicle(ped, car, -1)
                
                                        local string = "Your ".. carname.." spawned"
                                        RageUI.Text({
                                            message = string;
                                        })
                                    end
                                end)   
                            end
                
                        end, function()
                            ---Panels
                        end)
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