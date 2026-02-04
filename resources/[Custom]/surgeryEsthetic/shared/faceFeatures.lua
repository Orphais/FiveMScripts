print("^3[SURGERY DEBUG]^7 Loading faceFeatures.lua...")

FaceFeatures = {}

print("^3[SURGERY DEBUG]^7 faceFeatures.lua - creating traits table...")

-- Liste des traits modifiables avec SetPedFaceFeature
FaceFeatures.traits = {
    -- NEZ
    {id = 0, name = "Nose Width", category = "Nose", description = "Largeur du nez", min = -1.0, max = 1.0},
    {id = 1, name = "Nose Peak Height", category = "Nose", description = "Hauteur du nez", min = -1.0, max = 1.0},
    {id = 2, name = "Nose Peak Length", category = "Nose", description = "Longueur du nez", min = -1.0, max = 1.0},
    {id = 3, name = "Nose Bone Height", category = "Nose", description = "Hauteur de l'os du nez", min = -1.0, max = 1.0},
    {id = 4, name = "Nose Peak Lowering", category = "Nose", description = "Abaissement du nez", min = -1.0, max = 1.0},
    {id = 5, name = "Nose Bone Twist", category = "Nose", description = "Torsion du nez", min = -1.0, max = 1.0},

    -- SOURCILS
    {id = 6, name = "Eyebrow Height", category = "Eyebrows", description = "Hauteur des sourcils", min = -1.0, max = 1.0},
    {id = 7, name = "Eyebrow Depth", category = "Eyebrows", description = "Profondeur des sourcils", min = -1.0, max = 1.0},

    -- POMMETTES ET JOUES
    {id = 8, name = "Cheekbone Height", category = "Cheeks", description = "Hauteur des pommettes", min = -1.0, max = 1.0},
    {id = 9, name = "Cheekbone Width", category = "Cheeks", description = "Largeur des pommettes", min = -1.0, max = 1.0},
    {id = 10, name = "Cheek Width", category = "Cheeks", description = "Largeur des joues", min = -1.0, max = 1.0},

    -- YEUX
    {id = 11, name = "Eyes Opening", category = "Eyes", description = "Ouverture des yeux", min = -1.0, max = 1.0},

    -- LÈVRES
    {id = 12, name = "Lips Thickness", category = "Lips", description = "Épaisseur des lèvres", min = -1.0, max = 1.0},

    -- MÂCHOIRE
    {id = 13, name = "Jaw Bone Width", category = "Jaw", description = "Largeur de la mâchoire", min = -1.0, max = 1.0},
    {id = 14, name = "Jaw Bone Length", category = "Jaw", description = "Longueur de la mâchoire", min = -1.0, max = 1.0},

    -- MENTON
    {id = 15, name = "Chin Height", category = "Chin", description = "Hauteur du menton", min = -1.0, max = 1.0},
    {id = 16, name = "Chin Length", category = "Chin", description = "Longueur du menton", min = -1.0, max = 1.0},
    {id = 17, name = "Chin Width", category = "Chin", description = "Largeur du menton", min = -1.0, max = 1.0},
    {id = 18, name = "Chin Hole Size", category = "Chin", description = "Fossette du menton", min = -1.0, max = 1.0},

    -- COU
    {id = 19, name = "Neck Thickness", category = "Neck", description = "Épaisseur du cou", min = -1.0, max = 1.0}
}

-- Catégories pour l'organisation du menu
FaceFeatures.categories = {
    {id = "Nose", label = "Nez", icon = "fas fa-air-freshener"},
    {id = "Eyebrows", label = "Sourcils", icon = "fas fa-grip-lines"},
    {id = "Cheeks", label = "Joues & Pommettes", icon = "fas fa-smile"},
    {id = "Eyes", label = "Yeux", icon = "fas fa-eye"},
    {id = "Lips", label = "Lèvres", icon = "fas fa-kiss"},
    {id = "Jaw", label = "Mâchoire", icon = "fas fa-square"},
    {id = "Chin", label = "Menton", icon = "fas fa-chevron-down"},
    {id = "Neck", label = "Cou", icon = "fas fa-arrows-alt-v"}
}

-- Obtenir les traits d'une catégorie
function FaceFeatures.getTraitsByCategory(category)
    local traits = {}
    for _, trait in ipairs(FaceFeatures.traits) do
        if trait.category == category then
            table.insert(traits, trait)
        end
    end
    return traits
end

-- Obtenir un trait par ID
function FaceFeatures.getTraitById(id)
    for _, trait in ipairs(FaceFeatures.traits) do
        if trait.id == id then
            return trait
        end
    end
    return nil
end

-- Vérifier si un PED est un freemode PED
function FaceFeatures.isFreemodePed(ped)
    local model = GetEntityModel(ped)
    local maleFreemode = GetHashKey("mp_m_freemode_01")
    local femaleFreemode = GetHashKey("mp_f_freemode_01")

    return model == maleFreemode or model == femaleFreemode
end

-- Appliquer un trait à un PED
function FaceFeatures.applyTrait(ped, traitId, value)
    if not FaceFeatures.isFreemodePed(ped) then
        return false, "PED must be freemode model"
    end

    SetPedFaceFeature(ped, traitId, value)
    return true
end

-- Appliquer tous les traits depuis une table
function FaceFeatures.applyAllTraits(ped, traitsData)
    if not FaceFeatures.isFreemodePed(ped) then
        return false, "PED must be freemode model"
    end

    for traitId, value in pairs(traitsData) do
        SetPedFaceFeature(ped, tonumber(traitId), value)
    end

    return true
end
