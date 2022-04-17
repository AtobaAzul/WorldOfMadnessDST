-- Imports
local TECH = GLOBAL.TECH
local TechTree = GLOBAL.require("techtree")
local AllRecipes = GLOBAL.AllRecipes
modimport("features/harsh_season_aid/harsh_season_helper.lua")

-- Make Endothermic Fire available from the start
if AllRecipes["coldfire"] ~= nil then
    AllRecipes["coldfire"].level = TechTree.Create(TECH.NONE)
end
