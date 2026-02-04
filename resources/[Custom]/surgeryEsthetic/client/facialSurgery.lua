print("^3[SURGERY DEBUG]^7 Loading facialSurgery.lua...")

local currentFaceData = {}
local selectedPatientForFacial = nil
local inPreview = false

-- Initialiser les données du visage
function initializeFaceData()
    local data = {}
    for _, trait in ipairs(FaceFeatures.traits) do
        data[trait.id] = 0.0 -- Valeur par défaut
    end
    return data
end

-- Ouvrir le menu de chirurgie faciale
function openFacialSurgeryMenu()
    local menuOptions = {}

    -- Option pour se modifier soi-même
    table.insert(menuOptions, {
        title = 'Modify Yourself',
        description = 'Modify your own face',
        icon = 'fas fa-user-circle',
        onSelect = function()
            selectedPatientForFacial = GetPlayerServerId(PlayerId())
            currentFaceData = initializeFaceData()
            openCategorySelectionMenu()
        end
    })

    -- Option pour modifier un patient proche
    table.insert(menuOptions, {
        title = 'Modify Patient',
        description = 'Modify a nearby patient',
        icon = 'fas fa-user-md',
        onSelect = function()
            local closestPlayer, distance = getClosestPlayer()
            if not closestPlayer then
                notify("No player nearby", "error")
                return
            end
            selectedPatientForFacial = closestPlayer
            currentFaceData = initializeFaceData()
            notify(string.format("Selected patient: Player %s", closestPlayer), "success")
            openCategorySelectionMenu()
        end
    })

    lib.registerContext({
        id = 'facial_surgery_main',
        title = 'Facial Surgery',
        options = menuOptions
    })

    lib.showContext('facial_surgery_main')
end

-- Menu de sélection de catégorie
function openCategorySelectionMenu()
    local menuOptions = {}

    for _, category in ipairs(FaceFeatures.categories) do
        table.insert(menuOptions, {
            title = category.label,
            description = 'Modify ' .. category.label,
            icon = category.icon,
            onSelect = function()
                openTraitMenu(category.id)
            end
        })
    end

    -- Option pour appliquer les modifications
    table.insert(menuOptions, {
        title = '✅ Apply Surgery',
        description = 'Apply all modifications',
        icon = 'fas fa-check',
        onSelect = function()
            confirmFacialSurgery()
        end
    })

    -- Option pour annuler
    table.insert(menuOptions, {
        title = '❌ Cancel',
        description = 'Cancel all modifications',
        icon = 'fas fa-times',
        onSelect = function()
            selectedPatientForFacial = nil
            currentFaceData = {}
            notify("Surgery cancelled", "info")
        end
    })

    lib.registerContext({
        id = 'facial_categories',
        title = 'Select Face Part',
        menu = 'facial_surgery_main',
        options = menuOptions
    })

    lib.showContext('facial_categories')
end

-- Menu des traits d'une catégorie
function openTraitMenu(categoryId)
    local traits = FaceFeatures.getTraitsByCategory(categoryId)
    local menuOptions = {}

    for _, trait in ipairs(traits) do
        local currentValue = currentFaceData[trait.id] or 0.0
        table.insert(menuOptions, {
            title = trait.name,
            description = string.format('%s (Current: %.2f)', trait.description, currentValue),
            icon = 'fas fa-sliders-h',
            onSelect = function()
                openTraitAdjustment(trait)
            end
        })
    end

    table.insert(menuOptions, {
        title = '← Back',
        icon = 'fas fa-arrow-left',
        onSelect = function()
            openCategorySelectionMenu()
        end
    })

    lib.registerContext({
        id = 'facial_traits_' .. categoryId,
        title = FaceFeatures.categories[getCategoryIndex(categoryId)].label,
        menu = 'facial_categories',
        options = menuOptions
    })

    lib.showContext('facial_traits_' .. categoryId)
end

-- Obtenir l'index d'une catégorie
function getCategoryIndex(categoryId)
    for i, cat in ipairs(FaceFeatures.categories) do
        if cat.id == categoryId then
            return i
        end
    end
    return 1
end

-- Ajuster un trait spécifique
function openTraitAdjustment(trait)
    local input = lib.inputDialog(trait.name, {
        {
            type = 'slider',
            label = trait.description,
            description = 'Ajustez la valeur (-1.0 à 1.0)',
            required = true,
            default = math.floor((currentFaceData[trait.id] or 0.0) * 100),
            min = -100,
            max = 100,
            step = 1
        }
    })

    if input then
        local value = input[1] / 100.0
        currentFaceData[trait.id] = value

        -- Aperçu en temps réel sur le patient
        if selectedPatientForFacial == GetPlayerServerId(PlayerId()) then
            local ped = PlayerPedId()
            if FaceFeatures.isFreemodePed(ped) then
                SetPedFaceFeature(ped, trait.id, value)
                notify(string.format("%s adjusted to %.2f", trait.name, value), "success")
            else
                notify("You must be a freemode character!", "error")
            end
        end

        openTraitMenu(trait.category)
    else
        openTraitMenu(trait.category)
    end
end

-- Confirmer la chirurgie faciale
function confirmFacialSurgery()
    if not selectedPatientForFacial then
        notify("No patient selected", "error")
        return
    end

    local input = lib.alertDialog({
        header = 'Confirm Surgery',
        content = string.format('Apply facial modifications to Player %s?', selectedPatientForFacial),
        centered = true,
        cancel = true
    })

    if input == 'confirm' then
        TriggerServerEvent('surgeryEsthetic:server:performFacialSurgery', selectedPatientForFacial, currentFaceData)
        notify("Facial surgery performed successfully!", "success")
        selectedPatientForFacial = nil
        currentFaceData = {}
    else
        openCategorySelectionMenu()
    end
end

-- Event pour appliquer les modifications faciales
RegisterNetEvent('surgeryEsthetic:client:applyFacialSurgery', function(faceData)
    local ped = PlayerPedId()

    if not FaceFeatures.isFreemodePed(ped) then
        notify("You must be a freemode character (mp_m_freemode_01 or mp_f_freemode_01)!", "error")
        return
    end

    -- Appliquer tous les traits
    for traitId, value in pairs(faceData) do
        SetPedFaceFeature(ped, tonumber(traitId), value)
    end

    notify("Your facial surgery was successful!", "success")
    print("^2[Surgery Esthetic]^7 Applied facial modifications")
end)

print("^3[SURGERY DEBUG]^7 facialSurgery.lua loaded")
