local QBCore = exports['qb-core']:GetCoreObject()

-- Callback pour obtenir les joueurs à proximité
QBCore.Functions.CreateCallback('surgeryEsthetic:server:getNearbyPlayers', function(source, cb)
    local src = source
    local players = {}
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)

    for _, playerId in ipairs(GetPlayers()) do
        local targetId = tonumber(playerId)
        if targetId ~= src then
            local targetPed = GetPlayerPed(targetId)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance <= Config.maxDistance then
                local targetPlayer = QBCore.Functions.GetPlayer(targetId)
                if targetPlayer then
                    table.insert(players, {
                        id = targetId,
                        name = GetPlayerName(targetId),
                        citizenid = targetPlayer.PlayerData.citizenid,
                        distance = math.floor(distance * 100) / 100
                    })
                end
            end
        end
    end

    cb(players)
end)

-- Callback pour effectuer la chirurgie
QBCore.Functions.CreateCallback('surgeryEsthetic:server:performSurgery', function(source, cb, patientId, model)
    local src = source
    local medic = QBCore.Functions.GetPlayer(src)
    local patient = QBCore.Functions.GetPlayer(patientId)

    -- Validation du médecin
    if not medic then
        cb({success = false, message = "Medic not found"})
        return
    end

    -- Vérifier job et grade
    local medicJob = medic.PlayerData.job.name
    local medicGrade = medic.PlayerData.job.grade.level

    if not Config.authorizedJobs[medicJob] or medicGrade < Config.minimumGrade then
        cb({success = false, message = Config.messages.noPermission})
        return
    end

    -- Validation du patient
    if not patient then
        cb({success = false, message = "Patient not found or offline"})
        return
    end

    -- Vérifier la distance
    local medicPed = GetPlayerPed(src)
    local patientPed = GetPlayerPed(patientId)
    local medicCoords = GetEntityCoords(medicPed)
    local patientCoords = GetEntityCoords(patientPed)
    local distance = #(medicCoords - patientCoords)

    if distance > Config.maxDistance then
        cb({success = false, message = "Patient is too far away"})
        return
    end

    -- Valider le modèle PED
    if not PedModels.isValid(model) then
        cb({success = false, message = "Invalid PED model"})
        return
    end

    -- Vérifier les fonds du patient
    local patientMoney = 0
    if Config.paymentType == 'cash' then
        patientMoney = patient.PlayerData.money.cash
    else
        patientMoney = patient.PlayerData.money.bank
    end

    if patientMoney < Config.surgeryPrice then
        cb({success = false, message = Config.messages.insufficientFunds})
        return
    end

    -- Traiter le paiement
    if Config.whoPaysCost == 'patient' then
        patient.Functions.RemoveMoney(Config.paymentType, Config.surgeryPrice, "plastic-surgery")
        medic.Functions.AddMoney(Config.paymentType, Config.medicCommission, "surgery-commission")
    else
        medic.Functions.RemoveMoney(Config.paymentType, Config.surgeryPrice, "plastic-surgery-cost")
    end

    -- Sauvegarder le PED dans les métadonnées
    patient.Functions.SetMetaData('surgeryPed', model)

    -- Appliquer le PED au client
    TriggerClientEvent('surgeryEsthetic:client:applyPedModel', patientId, model)

    -- Enregistrer dans la base de données
    if Config.enableAuditLog then
        MySQL.insert('INSERT INTO surgery_records (medic_citizenid, patient_citizenid, model, cost, date) VALUES (?, ?, ?, ?, NOW())', {
            medic.PlayerData.citizenid,
            patient.PlayerData.citizenid,
            model,
            Config.surgeryPrice
        })
    end

    -- Notifications
    TriggerClientEvent('QBCore:Notify', src, Config.messages.surgerySuccess, 'success')
    TriggerClientEvent('QBCore:Notify', patientId, Config.messages.surgeryReceived, 'success')

    cb({
        success = true,
        message = Config.messages.surgerySuccess,
        patientName = GetPlayerName(patientId),
        model = model,
        cost = Config.surgeryPrice,
        commission = Config.medicCommission
    })
end)
