print("^3[SURGERY DEBUG]^7 Loading utils_standalone.lua...")

-- Notification simple
function notify(message, type)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

-- Dessine un texte 3D
function drawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Vérifie si le joueur est dans une zone de chirurgie
function isInSurgeryLocation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for _, location in ipairs(Config.surgeryLocations) do
        local distance = #(playerCoords - location.coords)
        if distance <= location.radius then
            return true, location
        end
    end

    return false, nil
end

-- Trouve le joueur le plus proche
function getClosestPlayer()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = nil
    local closestDistance = Config.maxDistance

    local players = GetActivePlayers()

    for _, player in ipairs(players) do
        if player ~= PlayerId() then
            local targetPed = GetPlayerPed(player)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = GetPlayerServerId(player)
            end
        end
    end

    return closestPlayer, closestDistance
end

print("^3[SURGERY DEBUG]^7 utils_standalone.lua loaded")
