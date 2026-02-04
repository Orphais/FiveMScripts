RegisterCommand("pos", function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    print(pos)
end, false)

RegisterCommand("tp", function()
    local id = PlayerId()
    StartPlayerTeleport(id, vec3(-566.653625, 327.710022, 84.434326), 90, true, true, true)
    print("tp")
end)

RegisterCommand("tp1", function(source, args, rawCommand)
    if #args < 3 then
        print("Utilisation : /tp <x> <y> <z>")
        return
    end

    local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
    
    if x and y and z then
        local id = PlayerId()
        StartPlayerTeleport(id, x, y, z, 90, true, true, true)
        print("Téléportation réussie !")
    else
        print("Coordonnées invalides !")
    end
end, false)



