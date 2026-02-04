print("^3[SURGERY DEBUG]^7 1. Starting client_standalone.lua")

local selectedPatient = nil
local selectedModel = nil
local inSurgeryZone = false

print("^3[SURGERY DEBUG]^7 2. Variables initialized")

-- Initialiser les blips pour les hôpitaux
function initializeBlips()
    print("^3[SURGERY DEBUG]^7 3. initializeBlips() called")
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

print("^3[SURGERY DEBUG]^7 4. About to create marker thread")

-- Thread pour gérer les marqueurs et l'interaction
CreateThread(function()
    print("^3[SURGERY DEBUG]^7 5. Marker thread started")
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

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
            if IsControlJustReleased(0, 38) then
                openMainMenu()
            end
        else
            inSurgeryZone = false
        end

        Wait(sleep)
    end
end)

-- Menu pour passer en freemode PED
function openFreemodeSwitchMenu()
    lib.registerContext({
        id = 'freemode_switch',
        title = 'Switch to Freemode PED',
        menu = 'surgery_main',
        options = {
            {
                title = '♂️ Male Freemode',
                description = 'Switch to male freemode character',
                icon = 'fas fa-male',
                onSelect = function()
                    switchToFreemodePed('male')
                end
            },
            {
                title = '♀️ Female Freemode',
                description = 'Switch to female freemode character',
                icon = 'fas fa-female',
                onSelect = function()
                    switchToFreemodePed('female')
                end
            }
        }
    })

    lib.showContext('freemode_switch')
end

-- Changer en freemode PED
function switchToFreemodePed(gender)
    local model = gender == 'male' and 'mp_m_freemode_01' or 'mp_f_freemode_01'
    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(model)

    -- Charger le modèle
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    -- Appliquer le modèle
    SetPlayerModel(PlayerId(), modelHash)
    Wait(100)

    -- IMPORTANT: Initialiser le HeadBlend pour que SetPedFaceFeature fonctionne!
    local newPed = PlayerPedId()
    SetPedDefaultComponentVariation(newPed)

    -- Configurer le HeadBlend de base (parents: père 0, mère 0, mix 50%)
    SetPedHeadBlendData(newPed, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.0, false)

    -- Réinitialiser tous les traits à 0 (neutre)
    for i = 0, 19 do
        SetPedFaceFeature(newPed, i, 0.0)
    end

    -- Libérer le modèle
    SetModelAsNoLongerNeeded(modelHash)

    notify(string.format("You are now a %s freemode character!", gender), "success")
    notify("You can now use facial surgery!", "info")

    print(string.format('^2[Surgery Esthetic]^7 Switched to %s freemode PED with HeadBlend initialized', gender))
end

-- Ouvrir le menu principal
function openMainMenu()
    local menuOptions = {
        {
            title = '🎭 Facial Surgery',
            description = 'Modify facial features (nose, lips, eyes, etc.)',
            icon = 'fas fa-user-edit',
            onSelect = function()
                openFacialSurgeryMenu()
            end
        },
        {
            title = '🆓 Switch to Freemode PED',
            description = 'Convert to freemode character (required for facial surgery)',
            icon = 'fas fa-user-circle',
            onSelect = function()
                openFreemodeSwitchMenu()
            end
        },
        {
            title = '👤 Full PED Change',
            description = 'Change to any character model',
            icon = 'fas fa-users',
            onSelect = function()
                selectedPatient = {id = GetPlayerServerId(PlayerId()), distance = 0}
                openCategoryMenu()
            end
        }
    }

    if selectedPatient then
        table.insert(menuOptions, {
            title = 'Perform Surgery',
            description = string.format('Perform surgery on Player %s', selectedPatient.id),
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
        title = 'Plastic Surgery Menu (Standalone)',
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

    selectedPatient = {
        id = closestPlayer,
        distance = distance
    }

    notify(string.format("Selected patient: Player %s (%.1fm)", closestPlayer, distance), "success")
    TriggerServerEvent('surgeryEsthetic:server:notifyPatient', closestPlayer)

    openMainMenu()
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
                description = string.format('Perform surgery on Player %s\nModel: %s\n(FREE in standalone mode)',
                    selectedPatient.id, selectedModel),
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

    notify("Performing surgery...", "info")

    Wait(2000)

    TriggerServerEvent('surgeryEsthetic:server:performSurgery', selectedPatient.id, selectedModel)

    notify(Config.messages.surgerySuccess, "success")
    selectedPatient = nil
    selectedModel = nil
end

-- Event pour appliquer un modèle de PED
RegisterNetEvent('surgeryEsthetic:client:applyPedModel', function(model)
    if not PedModels.isValid(model) then
        notify("Invalid PED model", "error")
        return
    end

    local playerPed = PlayerPedId()
    local modelHash = GetHashKey(model)

    -- Charger le modèle
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end

    -- Appliquer le modèle
    SetPlayerModel(PlayerId(), modelHash)
    SetPedDefaultComponentVariation(PlayerPedId())

    -- Libérer le modèle
    SetModelAsNoLongerNeeded(modelHash)

    notify(Config.messages.surgeryReceived, "success")
    print(string.format('^2[Surgery Esthetic]^7 Applied PED model: %s', model))
end)

-- Event pour notifier le patient qu'il a été sélectionné
RegisterNetEvent('surgeryEsthetic:client:notifySelected', function()
    notify(Config.messages.patientSelected, "info")
end)

print("^3[SURGERY DEBUG]^7 6. About to create init thread")

-- Initialiser au démarrage
CreateThread(function()
    print("^3[SURGERY DEBUG]^7 7. Init thread started, waiting 2s...")
    Wait(2000)
    print("^3[SURGERY DEBUG]^7 8. Calling initializeBlips()...")
    initializeBlips()
    print('^2[Surgery Esthetic]^7 Client initialized successfully (STANDALONE MODE)')
    print("^3[SURGERY DEBUG]^7 9. Initialization complete!")
end)

print("^3[SURGERY DEBUG]^7 10. End of client_standalone.lua file")

-- ========== FACIAL SURGERY SYSTEM ==========
print("^3[SURGERY DEBUG]^7 11. Loading facial surgery functions...")

local currentFaceData = {}
local selectedPatientForFacial = nil

-- Traits du visage modifiables
local faceTraits = {
    {id = 0, name = "Nose Width", desc = "Largeur du nez"},
    {id = 1, name = "Nose Peak Height", desc = "Hauteur du nez"},
    {id = 2, name = "Nose Peak Length", desc = "Longueur du nez"},
    {id = 12, name = "Lips Thickness", desc = "Épaisseur des lèvres"},
    {id = 11, name = "Eyes Opening", desc = "Ouverture des yeux"},
    {id = 8, name = "Cheekbone Height", desc = "Hauteur des pommettes"},
    {id = 13, name = "Jaw Width", desc = "Largeur de la mâchoire"},
    {id = 15, name = "Chin Height", desc = "Hauteur du menton"}
}

-- Menu de chirurgie faciale
function openFacialSurgeryMenu()
    lib.registerContext({
        id = 'facial_surgery_main',
        title = 'Facial Surgery',
        options = {
            {
                title = 'Modify Yourself',
                description = 'Modify your own face',
                icon = 'fas fa-user-circle',
                onSelect = function()
                    selectedPatientForFacial = GetPlayerServerId(PlayerId())
                    currentFaceData = {}
                    openFacialTraitsMenu()
                end
            }
        }
    })
    lib.showContext('facial_surgery_main')
end

-- Menu des traits
function openFacialTraitsMenu()
    local options = {}

    for _, trait in ipairs(faceTraits) do
        table.insert(options, {
            title = trait.name,
            description = trait.desc,
            icon = 'fas fa-sliders-h',
            onSelect = function()
                adjustFacialTrait(trait)
            end
        })
    end

    table.insert(options, {
        title = '✅ Apply Surgery',
        description = 'Apply all modifications',
        icon = 'fas fa-check',
        onSelect = function()
            applyFacialSurgery()
        end
    })

    lib.registerContext({
        id = 'facial_traits',
        title = 'Select Feature',
        menu = 'facial_surgery_main',
        options = options
    })

    lib.showContext('facial_traits')
end

-- Ajuster un trait
function adjustFacialTrait(trait)
    print(string.format("^3[SURGERY DEBUG]^7 Adjusting trait: %s (ID: %d)", trait.name, trait.id))

    local input = lib.inputDialog(trait.name, {
        {
            type = 'slider',
            label = trait.desc,
            description = '-100 à 100',
            required = true,
            default = math.floor((currentFaceData[trait.id] or 0.0) * 100),
            min = -100,
            max = 100,
            step = 5
        }
    })

    print(string.format("^3[SURGERY DEBUG]^7 Input received: %s", input and "YES" or "NO"))

    if input then
        local value = input[1] / 100.0
        print(string.format("^3[SURGERY DEBUG]^7 New value: %.2f", value))

        currentFaceData[trait.id] = value
        print(string.format("^3[SURGERY DEBUG]^7 Saved to currentFaceData[%d] = %.2f", trait.id, value))

        -- Aperçu en temps réel
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        print(string.format("^3[SURGERY DEBUG]^7 PED model: %d", model))

        local isFreemode = (model == GetHashKey("mp_m_freemode_01") or model == GetHashKey("mp_f_freemode_01"))
        print(string.format("^3[SURGERY DEBUG]^7 Is freemode: %s", isFreemode and "YES" or "NO"))

        if isFreemode then
            print(string.format("^3[SURGERY DEBUG]^7 Calling SetPedFaceFeature(%d, %d, %.2f)", ped, trait.id, value))
            SetPedFaceFeature(ped, trait.id, value)
            notify(string.format("%s: %.2f", trait.name, value), "success")
            print("^2[SURGERY DEBUG]^7 SetPedFaceFeature called successfully!")
        else
            notify("You must be freemode PED first!", "error")
            print("^1[SURGERY DEBUG]^7 ERROR: Not a freemode PED!")
        end

        openFacialTraitsMenu()
    else
        print("^3[SURGERY DEBUG]^7 Input cancelled")
        openFacialTraitsMenu()
    end
end

-- Appliquer la chirurgie
function applyFacialSurgery()
    if not selectedPatientForFacial then
        notify("No patient selected", "error")
        return
    end

    TriggerServerEvent('surgeryEsthetic:server:performFacialSurgery', selectedPatientForFacial, currentFaceData)
    notify("Facial surgery completed!", "success")
    selectedPatientForFacial = nil
    currentFaceData = {}
end

-- Event pour recevoir la chirurgie
RegisterNetEvent('surgeryEsthetic:client:applyFacialSurgery', function(faceData)
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local isFreemode = (model == GetHashKey("mp_m_freemode_01") or model == GetHashKey("mp_f_freemode_01"))

    if not isFreemode then
        notify("You must be freemode PED!", "error")
        return
    end

    for traitId, value in pairs(faceData) do
        SetPedFaceFeature(ped, tonumber(traitId), value)
    end

    notify("Your facial surgery was successful!", "success")
end)

print("^3[SURGERY DEBUG]^7 12. Facial surgery system loaded!")
