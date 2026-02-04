local QBCore = exports['qb-core']:GetCoreObject()

-- Créer la table de base de données au démarrage
CreateThread(function()
    if Config.enableAuditLog then
        MySQL.query([[
            CREATE TABLE IF NOT EXISTS surgery_records (
                id INT AUTO_INCREMENT PRIMARY KEY,
                medic_citizenid VARCHAR(50) NOT NULL,
                patient_citizenid VARCHAR(50) NOT NULL,
                model VARCHAR(100) NOT NULL,
                cost INT NOT NULL,
                date DATETIME NOT NULL,
                INDEX idx_medic (medic_citizenid),
                INDEX idx_patient (patient_citizenid),
                INDEX idx_date (date)
            )
        ]])
        print('^2[Surgery Esthetic]^7 Database table initialized')
    end
end)

-- Appliquer le PED sauvegardé au spawn
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    -- Attendre un peu pour que le joueur soit complètement chargé
    Wait(2000)

    -- Vérifier si le joueur a un PED sauvegardé
    if Player.PlayerData.metadata.surgeryPed then
        local savedPed = Player.PlayerData.metadata.surgeryPed

        -- Vérifier que le modèle est toujours valide
        if PedModels.isValid(savedPed) then
            TriggerClientEvent('surgeryEsthetic:client:applyPedModel', src, savedPed)
            print(string.format('^2[Surgery Esthetic]^7 Applied saved PED "%s" to player %s', savedPed, Player.PlayerData.citizenid))
        else
            -- Modèle invalide, réinitialiser
            Player.Functions.SetMetaData('surgeryPed', nil)
            print(string.format('^3[Surgery Esthetic]^7 Invalid saved PED for player %s, resetting', Player.PlayerData.citizenid))
        end
    end
end)

-- Commande admin pour voir l'historique des chirurgies
QBCore.Commands.Add('surgeryhistory', 'View plastic surgery history (Admin Only)', {{name = 'citizenid', help = 'Citizen ID (optional)'}}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    -- Vérifier les permissions admin
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command', 'error')
        return
    end

    local citizenid = args[1]

    if citizenid then
        -- Historique pour un joueur spécifique
        MySQL.query('SELECT * FROM surgery_records WHERE patient_citizenid = ? OR medic_citizenid = ? ORDER BY date DESC LIMIT 10', {
            citizenid,
            citizenid
        }, function(results)
            if not results or #results == 0 then
                TriggerClientEvent('QBCore:Notify', src, 'No surgery records found for this citizen', 'error')
                return
            end

            TriggerClientEvent('QBCore:Notify', src, string.format('Found %d surgery records (check console)', #results), 'success')

            print(string.format('^2[Surgery History]^7 Records for Citizen ID: %s', citizenid))
            for i, record in ipairs(results) do
                print(string.format('%d. Date: %s | Medic: %s | Patient: %s | Model: %s | Cost: $%d',
                    i, record.date, record.medic_citizenid, record.patient_citizenid, record.model, record.cost))
            end
        end)
    else
        -- Historique global (10 dernières chirurgies)
        MySQL.query('SELECT * FROM surgery_records ORDER BY date DESC LIMIT 10', {}, function(results)
            if not results or #results == 0 then
                TriggerClientEvent('QBCore:Notify', src, 'No surgery records found', 'error')
                return
            end

            TriggerClientEvent('QBCore:Notify', src, string.format('Found %d recent surgeries (check console)', #results), 'success')

            print('^2[Surgery History]^7 Recent Surgery Records:')
            for i, record in ipairs(results) do
                print(string.format('%d. Date: %s | Medic: %s | Patient: %s | Model: %s | Cost: $%d',
                    i, record.date, record.medic_citizenid, record.patient_citizenid, record.model, record.cost))
            end
        end)
    end
end)

-- Event pour notifier le patient qu'il a été sélectionné
RegisterNetEvent('surgeryEsthetic:server:notifyPatient', function(targetId)
    TriggerClientEvent('surgeryEsthetic:client:notifySelected', targetId)
end)

-- Event pour réinitialiser le PED d'un joueur (admin)
RegisterNetEvent('surgeryEsthetic:server:resetPed', function(targetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then return end

    -- Vérifier les permissions
    if not QBCore.Functions.HasPermission(src, 'admin') then
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command', 'error')
        return
    end

    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('QBCore:Notify', src, 'Target player not found', 'error')
        return
    end

    -- Réinitialiser le PED
    targetPlayer.Functions.SetMetaData('surgeryPed', nil)
    TriggerClientEvent('QBCore:Notify', src, string.format('Reset PED for player %s', GetPlayerName(targetId)), 'success')
    TriggerClientEvent('QBCore:Notify', targetId, 'Your appearance has been reset by an admin', 'info')

    print(string.format('^2[Surgery Esthetic]^7 Admin %s reset PED for player %s', Player.PlayerData.citizenid, targetPlayer.PlayerData.citizenid))
end)

print('^2[Surgery Esthetic]^7 Server initialized successfully')
