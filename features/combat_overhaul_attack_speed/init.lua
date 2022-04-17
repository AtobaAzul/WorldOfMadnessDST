-- Imports
local AllRecipes = GLOBAL.AllRecipes
modimport("features/combat_overhaul_attack_speed/all_players_overrides.lua")

-- Move some recipes around
if AllRecipes["katana"] ~= nil then
    AllRecipes["katana"].sortkey = GetRecipeSortKey("spear") + .1
end

if AllRecipes["cutlass_supreme"] ~= nil then
    AllRecipes["cutlass_supreme"].sortkey = GetRecipeSortKey("spear") + .2
end

if AllRecipes["trident"] ~= nil then
    AllRecipes["trident"].sortkey = GetRecipeSortKey("whip") + .2
end

if AllRecipes["staff_tornado"] ~= nil then
    AllRecipes["staff_tornado"].sortkey = GetRecipeSortKey("whip") + .3
end

if AllRecipes["shears"] ~= nil then
    AllRecipes["shears"].sortkey = GetRecipeSortKey("pitchfork") - .1
end

if AllRecipes["speargun"] ~= nil then
    AllRecipes["speargun"].sortkey = GetRecipeSortKey("boomerang") - .1
end
