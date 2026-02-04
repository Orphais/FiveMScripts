-- Commande pour supprimer les véhicules dans un rayon spécifié
RegisterCommand("supprveh", function(source, args, rawCommand)
    -- Vérifier si un rayon a été spécifié
    local radius = tonumber(args[1])
    
    if not radius then
        -- Si aucun rayon n'est spécifié, utiliser une valeur par défaut
        radius = 50.0
        TriggerEvent('chat:addMessage', {
            color = {255, 0, 0},
            multiline = true,
            args = {"Système", "Aucun rayon spécifié, utilisation de la valeur par défaut: 50.0m"}
        })
    end
    
    -- Obtenir la position du joueur
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    -- Compteur de véhicules supprimés
    local vehiclesDeleted = 0
    
    -- Obtenir tous les véhicules
    local vehicles = GetGamePool('CVehicle')
    
    -- Parcourir tous les véhicules et supprimer ceux dans le rayon
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)
        
        -- Si le véhicule est dans le rayon et n'est pas celui du joueur
        if distance <= radius and vehicle ~= GetVehiclePedIsIn(playerPed, false) then
            -- Supprimer le véhicule
            DeleteEntity(vehicle)
            vehiclesDeleted = vehiclesDeleted + 1
        end
    end
    
    -- Notification du nombre de véhicules supprimés
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {"Système", vehiclesDeleted .. " véhicule(s) ont été supprimé(s) dans un rayon de " .. radius .. "m"}
    })
end, false)

-- Ajouter une suggestion pour la commande
TriggerEvent('chat:addSuggestion', '/supprveh', 'Supprimer tous les véhicules dans un rayon spécifié', {
    { name = "rayon", help = "Rayon en mètres (par défaut: 50.0)" }
})