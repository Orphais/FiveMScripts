RegisterCommand("car", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)

    if not IsModelAVehicle(args[1]) then return end

    local hashModel = GetHashKey(args[1])
    RequestModel(hashModel)

    Citizen.CreateThread(function() 
        Citizen.Wait(0)
        while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
    end)
    
    local car = CreateVehicle(hashModel, pos, 90, true, false)
    SetPedIntoVehicle(ped, car, -1)
end, false)