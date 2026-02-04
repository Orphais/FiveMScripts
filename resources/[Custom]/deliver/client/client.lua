function showNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

-- Menu
RMenu.Add('deliver', 'deliver_main', RageUI.CreateMenu("Mission intérim", "Undefined for using SetSubtitle"))
RMenu:Get('deliver', 'deliver_main'):SetSubtitle("~b~SÉLECTIONNEZ VOTRE VEHICULE")
RMenu:Get('deliver', 'deliver_main').EnableMouse = false
RMenu:Get('deliver', 'deliver_main').Closed = function()
    -- TODO Perform action 
end;

RegisterCommand('delete-basic-rmenu', function()
    RMenu:Delete('deliver', 'deliver_main')
end, false)

local posSpawn = {
    {2392.955811, 4978.833008, 44.806950}, 
    {2398.795410, 4985.057617, 45.991718},
    {2387.757324, 4973.453613, 44.154602},
    {2405.549805, 4974.032715, 45.875645},
}

local posSpawn2 = {
    vector3(2289.538818, 4884.966797, 41.325466),
    vector3(2285.715332, 4889.211426, 41.132732)
}

local zonePolygon = {
    vector3(2225.762207, 5019.993164, 44.090572),
    vector3(2183.830322, 5062.320801, 44.246841),
    vector3(2193.572754, 5071.706543, 46.383060),
    vector3(2171.994629, 5093.686035, 45.860142),
    vector3(2221.301270, 5141.947266, 56.117882),
    vector3(2301.356689, 5064.382812, 45.793396),
    vector3(2261.137207, 5024.808105, 43.596149),
    vector3(2244.622314, 5038.212891, 44.362705)
}

function IsPointInPolygon(px, py, pz, polygon)
    local intersections = 0
    local count = #polygon

    for i = 1, count do
        local p1 = polygon[i]
        local p2 = polygon[(i % count) + 1]

        if ((p1.y > py) ~= (p2.y > py)) and
           (px < (p2.x - p1.x) * (py - p1.y) / (p2.y - p1.y) + p1.x) then
            intersections = intersections + 1
        end
    end

    -- Vérifier aussi la hauteur (Z)
    local minZ, maxZ = math.huge, -math.huge
    for _, p in pairs(polygon) do
        if p.z < minZ then minZ = p.z end
        if p.z > maxZ then maxZ = p.z end
    end

    return (intersections % 2) == 1 and (pz >= minZ and pz <= maxZ)
end

function ShowBottomText(message, duration)
    BeginTextCommandPrint("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandPrint(duration, true)
end

local begin = true
local step1 = false
local step2 = false

--Mark
Citizen.CreateThread(function()
    local ped = PlayerPedId()
    local pos = vector3(2414.102783, 4991.639160, 46.238426)
    
    while true do
        local interval = 1
        local posPed = GetEntityCoords(ped)
        local dist = GetDistanceBetweenCoords(posPed, pos, true)
        
        -- Etre à une distance < 10 pour voir le marqueur
        if dist < 10 then
            interval = 1
            DrawMarker(39, pos, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 0, 0, 170, 0, 1, 2, 0, nil, nil, 0)
            -- Etre à une distance < 2 pour interagir avec le marqueur
            if dist < 2 then
                AddTextEntry("INTERIM", "Appuyez sur ~INPUT_PICKUP~ pour plus d'information.")
                DisplayHelpTextThisFrame("INTERIM", false)
                
                -- Spawn
                if IsControlJustPressed(1, 38) then
                    RageUI.Visible(RMenu:Get('deliver', 'deliver_main'), not RageUI.Visible(RMenu:Get('deliver', 'deliver_main')))
                end
            end
        else 
            interval = 200
        end
        Citizen.Wait(interval)
    end
end)

-- menu
Citizen.CreateThread(function()
    while begin do 
        Citizen.Wait(0)
        if RageUI.Visible(RMenu:Get('deliver', 'deliver_main')) then
            RageUI.DrawContent({ header = true, glare = true, instructionalButton = true }, function()
                ---Items 
                RageUI.Button("Tracteur", "Faire apparaître un tracteur", { }, true, function(Hovered, Active, Selected)
                    if (Hovered) then

                    end
                    if (Active) then

                    end
                    if (Selected) then
                        -- spawn car + tp

                        local ped = PlayerPedId()
                        local posPed = GetEntityCoords(ped)

                        
                        local hashModel = GetHashKey("tractor2")
                        local trailerModel = GetHashKey("raketrailer")

                        --tractor
                        RequestModel(hashModel)
                        while not HasModelLoaded(hashModel) do Citizen.Wait(10) end

                        -- raketrailer
                        RequestModel(trailerModel)
                        while not HasModelLoaded(trailerModel) do Citizen.Wait(10) end

                        local posSpawnTractor = posPed

                        for key, value in pairs(posSpawn) do                        
                            if not IsPointObscuredByAMissionEntity(value[1], value[2], value[3], 1.0, 1.0, 1.0, 0) then
                                posSpawnTractor = vector3(value[1], value[2], value[3])
                                break  
                            end
                        end
                        
                        -- spawn tractor
                        tractor = CreateVehicle(hashModel, posSpawnTractor, 90, true, false)

                        --spawn trailer
                        trailer = CreateVehicle(trailerModel, posSpawnTractor.x, posSpawnTractor.y - 2, posSpawnTractor.z, 135, true, false)

                        attach = AttachVehicleToTrailer(tractor, trailer, 5)

                        local string = "Votre mission d'intérim commence."
                        RageUI.Text({
                            message = string;
                        })
                        RageUI.CloseAll()
                        step1 = true
                        begin = false
                    end
                end)   

            end, function()
                ---Panels
            end)
        end
    end
end)


-- STEP 1
Citizen.CreateThread(function()
    local blipPos, blipTractor
    local pourcMission = 0

    while true do
        Citizen.Wait(0)
        if step1 then
            local ped = PlayerPedId()

            if not blipPos then
                blipPos = AddBlipForCoord(vec3(2226.457520, 5024.311523, 44.504272))
                SetBlipSprite(blipPos, 1)
                SetBlipColour(blipPos, 69)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Champ")
                EndTextCommandSetBlipName(blipPos)
            end

            if not blipTractor then
                blipTractor = AddBlipForCoord(GetEntityCoords(tractor)) 
                SetBlipSprite(blipTractor, 846)
                SetBlipColour(blipTractor, 69)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Tracteur")
                EndTextCommandSetBlipName(blipTractor)
            end

            if tractor2 and tractor2 ~= 0 then
                SetBlipCoords(blipTractor, GetEntityCoords(tractor))
            end

            if IsPedInVehicle(ped, tractor, false) then
                -- Si le joueur est dans le tracteur
                local playerCoords = GetEntityCoords(ped)
    
                if IsPointInPolygon(playerCoords.x, playerCoords.y, playerCoords.z, zonePolygon) then
                    if GetEntitySpeed(tractor) * 3.6 > 15 then
                        Citizen.Wait(500)
                        pourcMission = pourcMission + 1
                        ShowBottomText("Travail du sol en cours : "..pourcMission.."%", 500)
                    else 
                        ShowBottomText("Gardez une vitesse constante supérieur à 15km/h", 500)
                    end

                else
                    ShowBottomText("Dirigez-vous vers le champ", 500)
                end     
                -- blip champ
                SetBlipAlpha(blipTractor, 0)
                SetBlipAlpha(blipPos, 255)
            else
                -- Si le joueur n'est pas dans le tracteur
                SetBlipAlpha(blipTractor, 255)
                SetBlipAlpha(blipPos, 0)
            end
        end
        if pourcMission >= 100 then
            step2 = true
            break;
        end
    end
end)


