print("^3[SURGERY DEBUG]^7 Loading config_standalone.lua...")

Config = {}

-- MODE STANDALONE (sans QB-Core)
print("^3[SURGERY DEBUG]^7 Config initialized")
Config.standalone = true

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
Config.selectionMethod = 'closest'
Config.maxDistance = 5.0

-- Options diverses
Config.enableBlips = true
Config.enableAuditLog = false  -- Désactivé pour standalone

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
    noPlayerNearby = "No player nearby",
    surgerySuccess = "Surgery completed successfully!",
    patientSelected = "You have been selected for surgery",
    surgeryReceived = "Your plastic surgery was successful!",
    menuPrompt = "[E] Open Surgery Menu (STANDALONE MODE - No restrictions)"
}
