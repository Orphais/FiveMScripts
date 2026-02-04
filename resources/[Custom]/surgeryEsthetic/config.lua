Config = {}

-- Jobs autorisés à effectuer des chirurgies
Config.authorizedJobs = {
    ['ambulance'] = true,
    ['doctor'] = true
}

-- Grade minimum requis
Config.minimumGrade = 2

-- Configuration des prix
Config.surgeryPrice = 5000          -- Prix de la chirurgie
Config.paymentType = 'cash'         -- Type de paiement (cash/bank)
Config.whoPaysCost = 'patient'      -- Qui paie (patient/medic)
Config.medicCommission = 500        -- Commission du médecin

-- Emplacements de chirurgie
Config.surgeryLocations = {
    {
        coords = vector3(298.22, -584.42, 43.26),
        radius = 2.0,
        label = "Pillbox Surgery",
        blip = {
            sprite = 403,
            color = 2,
            scale = 0.8,
            display = 4
        }
    },
    {
        coords = vector3(357.43, -1415.68, 32.51),
        radius = 2.0,
        label = "Sandy Surgery",
        blip = {
            sprite = 403,
            color = 2,
            scale = 0.8,
            display = 4
        }
    }
}

-- Méthode de sélection du patient
Config.selectionMethod = 'closest'  -- 'closest' ou 'target'
Config.maxDistance = 5.0            -- Distance maximale pour sélection

-- Options diverses
Config.enableCommand = false        -- Activer la commande /surgery
Config.enableAuditLog = true        -- Enregistrer dans la BDD
Config.enableBlips = true           -- Afficher les blips

-- Marker configuration
Config.marker = {
    type = 1,
    size = {x = 1.5, y = 1.5, z = 1.0},
    color = {r = 0, g = 255, b = 0, a = 100},
    bobUpAndDown = false,
    faceCamera = false,
    rotate = false
}

-- Messages
Config.messages = {
    noPermission = "You are not authorized to perform surgery",
    noPatient = "No patient selected",
    noPlayerNearby = "No player nearby",
    insufficientFunds = "Patient has insufficient funds",
    surgerySuccess = "Surgery completed successfully!",
    patientSelected = "You have been selected for surgery",
    surgeryReceived = "Your plastic surgery was successful!",
    menuPrompt = "[E] Open Surgery Menu"
}
