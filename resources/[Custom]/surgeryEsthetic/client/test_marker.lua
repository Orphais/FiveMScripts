-- TEST SIMPLE - Marker visible partout
print("^2[TEST MARKER]^7 Script loading...")

CreateThread(function()
    Wait(1000)
    print("^2[TEST MARKER]^7 Thread started!")

    -- Créer un blip de test au spawn
    local testBlip = AddBlipForCoord(0.0, 0.0, 71.0) -- Legion Square
    SetBlipSprite(testBlip, 1)
    SetBlipColour(testBlip, 2)
    SetBlipScale(testBlip, 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("TEST MARKER")
    EndTextCommandSetBlipName(testBlip)

    print("^2[TEST MARKER]^7 Blip created at Legion Square!")

    while true do
        Wait(0)

        -- Marker permanent à Legion Square
        DrawMarker(
            1, -- Type cylindre
            0.0, 0.0, 71.0, -- Legion Square
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            5.0, 5.0, 2.0, -- Grande taille
            255, 0, 0, 200, -- Rouge brillant
            false, false, 2, false, nil, nil, false
        )

        -- Texte 3D
        local onScreen, _x, _y = World3dToScreen2d(0.0, 0.0, 72.0)
        if onScreen then
            SetTextScale(0.5, 0.5)
            SetTextFont(4)
            SetTextProportional(1)
            SetTextColour(255, 255, 255, 255)
            SetTextEntry("STRING")
            SetTextCentre(true)
            AddTextComponentString("~r~TEST MARKER - If you see this, client works!")
            DrawText(_x, _y)
        end
    end
end)

print("^2[TEST MARKER]^7 Script loaded successfully!")
