-- PED
movePnj = false
tractorSpawn = false
missionCompleted = false
missionState = 0  -- 0: pas commencée, 1: livraisons en cours, 2: livraisons terminées, retour au mécanicien
deliveryPoints = {
    vector3(2420.416748, 4759.159668, 34.671833),
    vector3(2445.457275, 4795.605469, 35.089550),
    vector3(2435.971924, 4799.469238, 35.119701)
}
currentDeliveryPoint = 1
deliveredBales = 0
maxBales = 3

Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local pos = vector3(2307.248535, 4886.510742, 41.808289)
    
    while true do
        local interval = 1
        local posPed = GetEntityCoords(ped)
        local dist = GetDistanceBetweenCoords(posPed, pos, true)
        
        -- Etre à une distance < 40 pour voir le marqueur
        if dist < 40 then
            interval = 1
            --pnj

            if not DoesEntityExist(pnj) then
                local hashModel = GetHashKey("s_m_y_armymech_01")
                RequestModel(hashModel)
                while not HasModelLoaded(hashModel) do Citizen.Wait(10) end

                pnj = CreatePed(CIVMALE, hashModel, vector3(2307.248535, 4886.510742, 41.808289), 90, true, false)
                SetBlockingOfNonTemporaryEvents(pnj, true)
                SetEntityInvincible(pnj, true)
                Citizen.Wait(1000)
                FreezeEntityPosition(pnj, true)
            end
            -- Etre à une distance < 3 pour interagir
            if dist < 3 then
                AddTextEntry("INTERIM", "Appuyez sur ~INPUT_PICKUP~ pour appeler le mécanicien.")
                DisplayHelpTextThisFrame("INTERIM", false)
                
                -- Movement
                if IsControlJustPressed(1, 46) then 
                    movePnj = true
                    if tractorSpawn then 
                        TriggerEvent('chat:addMessage', {
                            color = {150, 0, 0},
                            multiline = true,
                            args = {"Quête fermier", "Votre tracteur a déjà été modifié."}
                        })
                    end
                end
            end
        else 
            interval = 200
        end
        Citizen.Wait(interval)
    end
end)

-- PNJ
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- On attend avant de vérifier à nouveau
        
        if movePnj and not tractorSpawn then     
                    
            FreezeEntityPosition(pnj, false)
            TaskGoToCoordAnyMeans(pnj, 2290.67, 4890.60, 41.16, 1.0, 0, false, 786603, 0)

            local animDict = "mini@repair"
            local animName = "fixing_a_ped"
            
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do 
                Citizen.Wait(10)
            end
            
            -- On attend que le PNJ arrive à destination
            while GetDistanceBetweenCoords(2290.67, 4890.60, 41.16, GetEntityCoords(pnj), false) > 1.3 do
                Citizen.Wait(100)
            end
            
            -- Une fois arrivé, on lance l'animation
            TaskPlayAnim(pnj, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
            
            -- spawn vehicles
            local hashModel = GetHashKey("tractor2")
            local trailerModel = GetHashKey("baletrailer")
            
            --tractor
            RequestModel(hashModel)
            while not HasModelLoaded(hashModel) do Citizen.Wait(10) end
            
            -- raketrailer
            RequestModel(trailerModel)
            while not HasModelLoaded(trailerModel) do Citizen.Wait(10) end
            
            
            Citizen.Wait(5000) -- On attend 5 secondes pour que l'animation se termine avant de spawn le véhicule
            -- spawn tractor
            posSpawnTractor = vector3(2290.67, 4890.60, 41.16)
            tractor2 = CreateVehicle(hashModel, posSpawnTractor, 90, true, false)
            
            --spawn baletrailer
            baletrailer = CreateVehicle(trailerModel, posSpawnTractor.x, posSpawnTractor.y - 2, posSpawnTractor.z, 135, true, false)
            
            attach = AttachVehicleToTrailer(tractor2, baletrailer, 5)
            
            -- On réinitialise movePnj pour éviter que ça se relance
            movePnj = false
            tractorSpawn = true
            TaskGoToCoordAnyMeans(pnj, vector3(2307.248535, 4886.510742, 41.808289), 1.0, 0, false, 786603, 0)
        end
    end
end)

-- Gestion des blips et mission de livraison de paille
Citizen.CreateThread(function() 
    local blipField = nil
    local blipTractor = nil
    local blipMission = nil
    local blipMechanic = nil
    
    while true do 
        Citizen.Wait(100)
        
        if tractorSpawn then
            local ped = PlayerPedId()
            local isPedInTractor = IsPedInVehicle(ped, tractor2, false)
            
            -- Gestion du blip du tracteur (seulement quand le joueur n'est pas dedans)
            if not isPedInTractor and tractor2 and tractor2 ~= 0 then
                if not DoesBlipExist(blipTractor) then
                    blipTractor = AddBlipForEntity(tractor2)
                    SetBlipSprite(blipTractor, 846)
                    SetBlipColour(blipTractor, 69)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Tracteur")
                    EndTextCommandSetBlipName(blipTractor)
                end
            elseif isPedInTractor and DoesBlipExist(blipTractor) then
                RemoveBlip(blipTractor)
                blipTractor = nil
            end
            
            -- Gestion des blips de mission selon l'état
            if isPedInTractor then
                -- Supprimer blip tracteur si existant
                if DoesBlipExist(blipTractor) then
                    RemoveBlip(blipTractor)
                    blipTractor = nil
                end
                
                if missionState == 0 or missionState == 1 then
                    -- Livraisons de paille en cours
                    if not DoesBlipExist(blipMission) and deliveredBales < maxBales then
                        blipMission = AddBlipForCoord(deliveryPoints[currentDeliveryPoint])
                        SetBlipSprite(blipMission, 514)
                        SetBlipColour(blipMission, 5)
                        SetBlipRoute(blipMission, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString("Point de livraison de paille")
                        EndTextCommandSetBlipName(blipMission)
                    end
                elseif missionState == 2 then
                    -- Retour au mécanicien
                    if not DoesBlipExist(blipMechanic) then
                        local mechanicPos = vector3(2307.248535, 4886.510742, 41.808289)
                        blipMechanic = AddBlipForCoord(mechanicPos)
                        SetBlipSprite(blipMechanic, 446)
                        SetBlipColour(blipMechanic, 5)
                        SetBlipRoute(blipMechanic, true)
                        BeginTextCommandSetBlipName("STRING")
                        AddTextComponentString("Retourner le tracteur au mécanicien")
                        EndTextCommandSetBlipName(blipMechanic)
                    end
                end
            else
                -- Si pas dans le tracteur, supprimer les blips de navigation
                if DoesBlipExist(blipMission) then
                    RemoveBlip(blipMission)
                    blipMission = nil
                end
                
                if DoesBlipExist(blipMechanic) then
                    RemoveBlip(blipMechanic)
                    blipMechanic = nil
                end
            end
            
            -- Vérifier si le joueur est au point de livraison
            local pedCoords = GetEntityCoords(ped)
            
            if missionState < 2 then
                local deliveryCoords = deliveryPoints[currentDeliveryPoint]
                local distToDelivery = GetDistanceBetweenCoords(pedCoords, deliveryCoords, true)
                
                if distToDelivery < 20 and deliveredBales < maxBales then
                    if isPedInTractor then
                        -- Message quand le joueur est dans le tracteur
                        AddTextEntry("DELIVER_BALES_INFO", "Sortez du tracteur pour décharger la paille.")
                        DisplayHelpTextThisFrame("DELIVER_BALES_INFO", false)
                    else
                        -- Message quand le joueur est sorti du tracteur
                        AddTextEntry("DELIVER_BALES_ACTION", "Appuyez sur ~INPUT_PICKUP~ pour décharger la paille.")
                        DisplayHelpTextThisFrame("DELIVER_BALES_ACTION", false)
                        
                        if IsControlJustPressed(1, 46) then
                            DeliverBales()
                        end
                    end
                end
            elseif missionState == 2 then
                -- Vérifier si le joueur est de retour au mécanicien
                local mechanicPos = vector3(2307.248535, 4886.510742, 41.808289)
                local distToMechanic = GetDistanceBetweenCoords(pedCoords, mechanicPos, true)
                
                if distToMechanic < 10 and not missionCompleted then
                    if isPedInTractor then
                        -- Message quand le joueur est dans le tracteur
                        AddTextEntry("RETURN_TRACTOR_INFO", "Sortez du tracteur pour terminer la mission.")
                        DisplayHelpTextThisFrame("RETURN_TRACTOR_INFO", false)
                    else
                        -- Message quand le joueur est sorti du tracteur
                        AddTextEntry("RETURN_TRACTOR_ACTION", "Appuyez sur ~INPUT_PICKUP~ pour rendre le tracteur.")
                        DisplayHelpTextThisFrame("RETURN_TRACTOR_ACTION", false)
                        
                        if IsControlJustPressed(1, 46) then
                            CompleteMission()
                        end
                    end
                end
            end
        end
    end
end)

-- Fonction pour délivrer la paille
function DeliverBales()
    local ped = PlayerPedId()
    
    -- Animation de déchargement
    local animDict = "amb@world_human_gardener_plant@male@exit"
    local animName = "exit"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do 
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 3000, 1, 0, false, false, false)
    
    TriggerEvent('chat:addMessage', {
        color = {0, 150, 0},
        multiline = true,
        args = {"Quête fermier", "Vous déchargez la paille de la remorque..."}
    })
    
    Citizen.Wait(3000)
    
    deliveredBales = deliveredBales + 1
    missionState = 1
    
    -- Supprimer le blip de mission actuel
    local blips = GetActiveBlips()
    for _, blip in pairs(blips) do
        if GetBlipSprite(blip) == 514 then
            RemoveBlip(blip)
        end
    end
    
    -- Passer au point de livraison suivant ou terminer les livraisons
    if deliveredBales < maxBales then
        currentDeliveryPoint = currentDeliveryPoint + 1
        if currentDeliveryPoint > #deliveryPoints then
            currentDeliveryPoint = 1
        end
        
        TriggerEvent('chat:addMessage', {
            color = {0, 150, 0},
            multiline = true,
            args = {"Quête fermier", "Paille livrée! Dirigez-vous vers le prochain point de livraison."}
        })
    else
        -- Toutes les livraisons terminées, retour au mécanicien
        missionState = 2
        
        TriggerEvent('chat:addMessage', {
            color = {0, 150, 0},
            multiline = true,
            args = {"Quête fermier", "Toutes les livraisons de paille sont terminées! Retournez le tracteur au mécanicien."}
        })
    end
end

-- Fonction pour terminer la mission
function CompleteMission()
    local ped = PlayerPedId()
    
    -- Animation de fin
    local animDict = "anim@mp_player_intincarthumbs_upbodhi@ps@"
    local animName = "enter"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do 
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, 2000, 1, 0, false, false, false)
    
    TriggerEvent('chat:addMessage', {
        color = {0, 150, 0},
        multiline = true,
        args = {"Quête fermier", "Merci pour votre travail! Voici votre récompense."}
    })
    
    Citizen.Wait(2000)
    
    -- Marquer comme terminé
    missionCompleted = true
    
    -- Ajouter ici le code pour donner une récompense au joueur
    -- Par exemple : TriggerServerEvent("farmer:giveReward")
    
    -- Nettoyer les blips et les entités
    local blips = GetActiveBlips()
    for _, blip in pairs(blips) do
        if GetBlipSprite(blip) == 446 or GetBlipSprite(blip) == 514 or GetBlipSprite(blip) == 9 or GetBlipSprite(blip) == 846 then
            RemoveBlip(blip)
        end
    end
    
    -- Supprimer le tracteur et la remorque
    if tractor2 and DoesEntityExist(tractor2) then
        DeleteVehicle(tractor2)
    end
    
    if baletrailer and DoesEntityExist(baletrailer) then
        DeleteVehicle(baletrailer)
    end
end

-- Fonction auxiliaire pour obtenir tous les blips actifs
function GetActiveBlips()
    local blips = {}
    for i = 0, 256 do
        local blip = GetFirstBlipInfoId(i)
        while DoesBlipExist(blip) do
            table.insert(blips, blip)
            blip = GetNextBlipInfoId(i)
        end
    end
    return blips
end