
Citizen.CreateThread(function()
    
    while true do 
        Citizen.Wait(0)
        local ped = PlayerPedId()
   
        SetPedConfigFlag(ped, 184, true)
        if GetIsTaskActive(ped, 165) then 
            SetPedIntoVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
        end

        local speed = GetEntitySpeed(GetVehiclePedIsUsing(ped)) * 3.6
        if speed < 50 then 
            -- Siege conducteur
            if IsControlJustPressed(1, 157) and IsVehicleSeatFree(GetVehiclePedIsUsing(ped), -1) then 
                SetPedIntoVehicle(ped, GetVehiclePedIsUsing(ped), -1)
            end
            -- Siege passager
            if IsControlJustPressed(1, 158) and IsVehicleSeatFree(GetVehiclePedIsUsing(ped), 0) then 
                SetPedIntoVehicle(ped, GetVehiclePedIsUsing(ped), 0)
            end
            -- Siege arrière gauche
            if IsControlJustPressed(1, 160) and IsVehicleSeatFree(GetVehiclePedIsUsing(ped), 1) then 
                SetPedIntoVehicle(ped, GetVehiclePedIsUsing(ped), 1)
            end
            -- Siege arrière droit
            if IsControlJustPressed(1, 164) and IsVehicleSeatFree(GetVehiclePedIsUsing(ped), 2) then 
                SetPedIntoVehicle(ped, GetVehiclePedIsUsing(ped), 2)
            end
        end
    end
end)