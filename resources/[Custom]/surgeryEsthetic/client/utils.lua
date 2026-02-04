local QBCore = exports['qb-core']:GetCoreObject()

-- Vérifie si le joueur est un médecin autorisé
function isAuthorizedMedic()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if not PlayerData or not PlayerData.job then
        return false
    end

    local job = PlayerData.job.name
    local grade = PlayerData.job.grade.level

    -- Vérifier si le job est autorisé
    if not Config.authorizedJobs[job] then
        return false
    end

    -- Vérifier le grade minimum
    if grade < Config.minimumGrade then
        return false
    end

    return true
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

-- Applique un modèle de PED au joueur
function applyPedModel(model)
    if not model or not PedModels.isValid(model) then
        notify(Config.messages.surgeryFailed or "Invalid PED model", "error")
        return false
    end

    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(model)

    -- Sauvegarder les armes
    local weapons = {}
    for weaponName, weaponData in pairs(QBCore.Shared.Weapons) do
        local weaponHash = GetHashKey(weaponName)
        if HasPedGotWeapon(playerPed, weaponHash, false) then
            local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
            table.insert(weapons, {
                weapon = weaponName,
                ammo = ammo
            })
        end
    end

    -- Charger le modèle
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    -- Appliquer le modèle
    SetPlayerModel(PlayerId(), modelHash)
    SetPedDefaultComponentVariation(PlayerPedId())

    -- Restaurer les armes
    Wait(100)
    local newPed = PlayerPedId()
    for _, weaponData in ipairs(weapons) do
        local weaponHash = GetHashKey(weaponData.weapon)
        GiveWeaponToPed(newPed, weaponHash, weaponData.ammo, false, false)
    end

    -- Libérer le modèle
    SetModelAsNoLongerNeeded(modelHash)

    return true
end

-- Affiche une notification
function notify(message, type)
    QBCore.Functions.Notify(message, type or "primary", 5000)
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
