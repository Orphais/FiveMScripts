function showNotification(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end

-- Menu
RMenu.Add('skinmenu', 'main', RageUI.CreateMenu("SKIN MENU", "Undefined for using SetSubtitle"))
RMenu:Get('skinmenu', 'main'):SetSubtitle("~b~CHOOSE YOUR SKIN")
RMenu:Get('skinmenu', 'main').EnableMouse = false
RMenu:Get('skinmenu', 'main').Closed = function()
    -- TODO Perform action 
end

-- Liste des modèles de PED
local pedModels = {
    -- Personnages masculins
    "a_m_m_acult_01", "a_m_m_afriamer_01", "a_m_m_beach_01", "a_m_m_beach_02", "a_m_m_bevhills_01", 
    "a_m_m_bevhills_02", "a_m_m_business_01", "a_m_m_eastsa_01", "a_m_m_eastsa_02", "a_m_m_farmer_01", 
    "a_m_m_fatlatin_01", "a_m_m_genfat_01", "a_m_m_genfat_02", "a_m_m_golfer_01", "a_m_m_hasjew_01", 
    "a_m_m_hillbilly_01", "a_m_m_hillbilly_02", "a_m_m_indian_01", "a_m_m_ktown_01", "a_m_m_malibu_01", 
    "a_m_m_mexcntry_01", "a_m_m_mexlabor_01", "a_m_m_og_boss_01", "a_m_m_paparazzi_01", "a_m_m_polynesian_01", 
    "a_m_m_prolhost_01", "a_m_m_rurmeth_01", "a_m_m_salton_01", "a_m_m_salton_02", "a_m_m_salton_03", 
    "a_m_m_salton_04", "a_m_m_skater_01", "a_m_m_skidrow_01", "a_m_m_socenlat_01", "a_m_m_soucent_01", 
    "a_m_m_soucent_02", "a_m_m_soucent_03", "a_m_m_soucent_04", "a_m_m_stlat_02", "a_m_m_tennis_01", 
    "a_m_m_tourist_01", "a_m_m_tramp_01", "a_m_m_trampbeac_01", "a_m_m_tranvest_01", "a_m_m_tranvest_02", 
    
    -- Personnages féminins
    "a_f_m_beach_01", "a_f_m_bevhills_01", "a_f_m_bevhills_02", "a_f_m_bodybuild_01", "a_f_m_business_02", 
    "a_f_m_downtown_01", "a_f_m_eastsa_01", "a_f_m_eastsa_02", "a_f_m_fatbla_01", "a_f_m_fatcult_01", 
    "a_f_m_fatwhite_01", "a_f_m_ktown_01", "a_f_m_ktown_02", "a_f_m_prolhost_01", "a_f_m_salton_01", 
    "a_f_m_skidrow_01", "a_f_m_soucent_01", "a_f_m_soucent_02", "a_f_m_tourist_01", "a_f_m_tramp_01",
    
    -- Personnages spéciaux
    "s_m_m_movalien_01", "s_m_m_movspace_01", "u_m_y_zombie_01", "s_m_y_swat_01", "s_m_y_cop_01",
    "s_m_m_snowcop_01", "s_m_y_fireman_01", "s_m_m_paramedic_01", "s_m_y_pilot_01", "s_m_y_prisoner_01",
    "s_m_y_robber_01", "u_m_y_juggernaut_01", "u_m_y_imporage", "a_c_cat_01", "a_c_chop", "a_c_husky",
    "a_c_poodle", "a_c_pug", "a_c_rabbit_01", "a_c_rat", "a_c_retriever", "a_c_rottweiler", "a_c_shepherd"
}

RegisterCommand('delete-skin-menu', function()
    RMenu:Delete('skinmenu', 'main')
end, false)

-- Commande pour ouvrir le menu de skins
RegisterCommand("skin", function(source, args, rawCommand)
    RageUI.Visible(RMenu:Get('skinmenu', 'main'), not RageUI.Visible(RMenu:Get('skinmenu', 'main')))
    showNotification("Menu des skins ouvert")
end, false)

-- Boucle principale du menu
CreateThread(function()
    while true do 
        Citizen.Wait(0)
        if RageUI.Visible(RMenu:Get('skinmenu', 'main')) then
            RageUI.DrawContent({ header = true, glare = true, instructionalButton = true }, function()
                -- Affichage des items du menu
                for i = 1, #pedModels do
                    RageUI.Button(pedModels[i], "Devenir " .. pedModels[i], {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            -- Changer le modèle du joueur
                            local hashModel = GetHashKey(pedModels[i])
                            
                            if IsModelInCdimage(hashModel) then
                                RequestModel(hashModel)
                                while not HasModelLoaded(hashModel) do 
                                    Citizen.Wait(10)
                                end
                                
                                -- Sauvegarder les armes actuelles
                                local weapons = {}
                                for k = 1, #Config.Weapons do
                                    local weapon = Config.Weapons[k]
                                    local weaponHash = GetHashKey(weapon)
                                    if HasPedGotWeapon(PlayerPedId(), weaponHash, false) then
                                        table.insert(weapons, weapon)
                                    end
                                end
                                
                                -- Appliquer le modèle
                                SetPlayerModel(PlayerId(), hashModel)
                                SetPedDefaultComponentVariation(PlayerPedId())
                                SetModelAsNoLongerNeeded(hashModel)
                                
                                -- Restaurer les armes
                                for k = 1, #weapons do
                                    local weaponHash = GetHashKey(weapons[k])
                                    GiveWeaponToPed(PlayerPedId(), weaponHash, 999, false, false)
                                end
                                
                                showNotification("Skin changé en: " .. pedModels[i])
                            else
                                showNotification("Modèle non valide: " .. pedModels[i])
                            end
                        end
                    end)
                end
            end, function()
                -- Panels (optionnel)
            end)
        end
    end
end)

-- Configuration pour les armes (à personnaliser selon vos besoins)
Config = {
    Weapons = {
        "WEAPON_PISTOL",
        "WEAPON_SMG",
        "WEAPON_PUMPSHOTGUN",
        "WEAPON_ASSAULTRIFLE",
        "WEAPON_SPECIALCARBINE",
        "WEAPON_STUNGUN",
        "WEAPON_NIGHTSTICK",
        "WEAPON_FLASHLIGHT",
        "WEAPON_KNIFE",
        "WEAPON_BAT",
        "WEAPON_FIREEXTINGUISHER"
    }
}