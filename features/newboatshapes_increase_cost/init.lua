-- Imports
local AllRecipes = GLOBAL.AllRecipes
modimport("features/newboatshapes_increase_cost/boat_overrides.lua")

-- Reduce Mast Cost
if AllRecipes["mast_item"] ~= nil then
    for k, ingredient in pairs(GetRecipeIngredients(AllRecipes["mast_item"])) do
        if GetIngredientPrefab(ingredient) == "silk" then
            ingredient.amount = 6
        end
    end
end
