-- Event pour notifier le patient qu'il a été sélectionné
RegisterNetEvent('surgeryEsthetic:server:notifyPatient', function(targetId)
    TriggerClientEvent('surgeryEsthetic:client:notifySelected', targetId)
end)

-- Event pour effectuer la chirurgie faciale
RegisterNetEvent('surgeryEsthetic:server:performFacialSurgery', function(patientId, faceData)
    local src = source

    -- Vérifier que le patient existe
    local patientPing = GetPlayerPing(patientId)
    if patientPing == 0 or patientPing == -1 then
        print(string.format('^1[Surgery Esthetic]^7 Patient %s not found or offline', patientId))
        return
    end

    -- Appliquer les modifications faciales au client
    TriggerClientEvent('surgeryEsthetic:client:applyFacialSurgery', patientId, faceData)

    -- Logs
    print(string.format('^2[Surgery Esthetic]^7 Player %s performed FACIAL surgery on Player %s',
        src, patientId))
end)

-- Event pour effectuer la chirurgie
RegisterNetEvent('surgeryEsthetic:server:performSurgery', function(patientId, model)
    local src = source

    -- Valider le modèle PED
    if not PedModels.isValid(model) then
        print(string.format('^1[Surgery Esthetic]^7 Invalid PED model attempt: %s', model))
        return
    end

    -- Vérifier que le patient existe
    local patientPing = GetPlayerPing(patientId)
    if patientPing == 0 or patientPing == -1 then
        print(string.format('^1[Surgery Esthetic]^7 Patient %s not found or offline', patientId))
        return
    end

    -- Appliquer le PED au client
    TriggerClientEvent('surgeryEsthetic:client:applyPedModel', patientId, model)

    -- Logs
    print(string.format('^2[Surgery Esthetic]^7 Player %s performed surgery on Player %s (Model: %s)',
        src, patientId, model))
end)

print('^2[Surgery Esthetic]^7 Server initialized successfully (STANDALONE MODE)')
