local QBCore = exports['qb-core']:GetCoreObject()
local selectedPatient = nil
local selectedModel = nil
local inSurgeryZone = false

-- Initialisation au chargement du joueur
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(2000)
    initializeBlips()
end)

-- Initialiser les blips pour les hôpitaux
function initializeBlips()
    if not Config.enableBlips then return end

    for _, location in ipairs(Config.surgeryLocations) do
        local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
        SetBlipSprite(blip, location.blip.sprite)
        SetBlipDisplay(blip, location.blip.display)
        SetBlipScale(blip, location.blip.scale)
        SetBlipColour(blip, location.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(location.label)
        EndTextCommandSetBlipName(blip)
    end
end

-- Thread pour gérer les marqueurs et l'interaction
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        -- Vérifier si le joueur est dans une zone de chirurgie
        local isInZone, currentLocation = isInSurgeryLocation()

        if isInZone then
            sleep = 0
            inSurgeryZone = true

            -- Dessiner le marqueur
            DrawMarker(
                Config.marker.type,
                currentLocation.coords.x,
                currentLocation.coords.y,
                currentLocation.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.marker.size.x,
                Config.marker.size.y,
                Config.marker.size.z,
                Config.marker.color.r,
                Config.marker.color.g,
                Config.marker.color.b,
                Config.marker.color.a,
                Config.marker.bobUpAndDown,
                Config.marker.faceCamera,
                2,
                Config.marker.rotate,
                nil, nil, false
            )

            -- Afficher le texte d'interaction
            drawText3D(currentLocation.coords.x, currentLocation.coords.y, currentLocation.coords.z, Config.messages.menuPrompt)

            -- Vérifier l'appui sur E
            if IsControlJustReleased(0, 38) then -- E key
                if isAuthorizedMedic() then
                    openMainMenu()
                else
                    notify(Config.messages.noPermission, "error")
                end
            end
        else
            inSurgeryZone = false
        end

        Wait(sleep)
    end
end)

-- Ouvrir le menu principal
function openMainMenu()
    local menuOptions = {
        {
            title = 'Select Patient',
            description = 'Choose a nearby patient for surgery',
            icon = 'fas fa-user-plus',
            onSelect = function()
                selectPatient()
            end
        }
    }

    -- Ajouter l'option de chirurgie si un patient est sélectionné
    if selectedPatient then
        table.insert(menuOptions, {
            title = 'Perform Surgery',
            description = string.format('Perform surgery on %s', selectedPatient.name),
            icon = 'fas fa-user-md',
            onSelect = function()
                openCategoryMenu()
            end
        })

        table.insert(menuOptions, {
            title = 'Cancel Selection',
            description = 'Clear selected patient',
            icon = 'fas fa-times',
            onSelect = function()
                selectedPatient = nil
                selectedModel = nil
                notify("Patient selection cancelled", "info")
                openMainMenu()
            end
        })
    end

    lib.registerContext({
        id = 'surgery_main',
        title = 'Plastic Surgery Menu',
        options = menuOptions
    })

    lib.showContext('surgery_main')
end

-- Sélectionner un patient
function selectPatient()
    local closestPlayer, distance = getClosestPlayer()

    if not closestPlayer then
        notify(Config.messages.noPlayerNearby, "error")
        return
    end

    -- Obtenir les infos du joueur depuis le serveur
    QBCore.Functions.TriggerCallback('surgeryEsthetic:server:getNearbyPlayers', function(players)
        if not players or #players == 0 then
            notify(Config.messages.noPlayerNearby, "error")
            return
        end

        -- Sélectionner automatiquement le joueur le plus proche
        local closest = players[1]
        for _, player in ipairs(players) do
            if player.distance < closest.distance then
                closest = player
            end
        end

        selectedPatient = closest
        notify(string.format("Selected patient: %s (%.1fm)", closest.name, closest.distance), "success")

        -- Notifier le patient
        TriggerServerEvent('surgeryEsthetic:server:notifyPatient', closest.id)

        openMainMenu()
    end)
end

-- Ouvrir le menu de catégories
function openCategoryMenu()
    lib.registerContext({
        id = 'surgery_categories',
        title = 'Select PED Category',
        menu = 'surgery_main',
        options = {
            {
                title = 'Male Models',
                description = string.format('%d available models', #PedModels.male),
                icon = 'fas fa-male',
                onSelect = function()
                    openModelMenu('male')
                end
            },
            {
                title = 'Female Models',
                description = string.format('%d available models', #PedModels.female),
                icon = 'fas fa-female',
                onSelect = function()
                    openModelMenu('female')
                end
            },
            {
                title = 'Special Models',
                description = string.format('%d available models', #PedModels.special),
                icon = 'fas fa-star',
                onSelect = function()
                    openModelMenu('special')
                end
            }
        }
    })

    lib.showContext('surgery_categories')
end

-- Ouvrir le menu des modèles
function openModelMenu(category)
    local models = {}

    if category == 'male' then
        models = PedModels.male
    elseif category == 'female' then
        models = PedModels.female
    elseif category == 'special' then
        models = PedModels.special
    end

    local menuOptions = {}

    for _, model in ipairs(models) do
        table.insert(menuOptions, {
            title = model,
            description = 'Select this model',
            icon = 'fas fa-user',
            onSelect = function()
                selectedModel = model
                confirmSurgery()
            end
        })
    end

    lib.registerContext({
        id = 'surgery_models_' .. category,
        title = string.format('%s Models', category:sub(1,1):upper()..category:sub(2)),
        menu = 'surgery_categories',
        options = menuOptions
    })

    lib.showContext('surgery_models_' .. category)
end

-- Confirmer la chirurgie
function confirmSurgery()
    if not selectedPatient or not selectedModel then
        notify("Missing patient or model selection", "error")
        return
    end

    lib.registerContext({
        id = 'surgery_confirm',
        title = 'Confirm Surgery',
        menu = 'surgery_categories',
        options = {
            {
                title = 'Confirm',
                description = string.format('Perform surgery on %s\nModel: %s\nCost: $%d',
                    selectedPatient.name, selectedModel, Config.surgeryPrice),
                icon = 'fas fa-check',
                onSelect = function()
                    performSurgery()
                end
            },
            {
                title = 'Cancel',
                description = 'Go back to model selection',
                icon = 'fas fa-times',
                onSelect = function()
                    selectedModel = nil
                    openCategoryMenu()
                end
            }
        }
    })

    lib.showContext('surgery_confirm')
end

-- Effectuer la chirurgie
function performSurgery()
    if not selectedPatient or not selectedModel then
        notify("Missing patient or model selection", "error")
        return
    end

    -- Afficher une animation de chargement
    QBCore.Functions.Progressbar("performing_surgery", "Performing surgery...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "amb@medic@standing@timeofdeath@base",
        anim = "base",
        flags = 49,
    }, {}, {}, function() -- Success
        -- Callback vers le serveur
        QBCore.Functions.TriggerCallback('surgeryEsthetic:server:performSurgery', function(result)
            if result.success then
                notify(result.message, "success")
                selectedPatient = nil
                selectedModel = nil
            else
                notify(result.message, "error")
            end
        end, selectedPatient.id, selectedModel)
    end, function() -- Cancel
        notify("Surgery cancelled", "error")
    end)
end

-- Event pour appliquer un modèle de PED
RegisterNetEvent('surgeryEsthetic:client:applyPedModel', function(model)
    if applyPedModel(model) then
        print(string.format('^2[Surgery Esthetic]^7 Applied PED model: %s', model))
    else
        print(string.format('^1[Surgery Esthetic]^7 Failed to apply PED model: %s', model))
    end
end)

-- Event pour notifier le patient qu'il a été sélectionné
RegisterNetEvent('surgeryEsthetic:client:notifySelected', function()
    notify(Config.messages.patientSelected, "info")
end)

-- Initialiser au démarrage
CreateThread(function()
    Wait(2000)
    initializeBlips()
end)

print('^2[Surgery Esthetic]^7 Client initialized successfully')
