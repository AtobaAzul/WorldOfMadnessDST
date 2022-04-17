-- Imports
local Prefabs = GLOBAL.Prefabs
local AllRecipes = GLOBAL.AllRecipes
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

local Originaldestroystructure = nil
local SpawnLootPrefab = nil

local function destroystructure(staff, target)
    if Originaldestroystructure ~= nil and SpawnLootPrefab ~= nil then
        local recipe = AllRecipes[target.prefab]
        if recipe == nil or recipe.no_deconstruction then
            return
        end

        local ingredient_percent =
        (   (target.components.finiteuses ~= nil and target.components.finiteuses:GetPercent()) or
            (target.components.fueled ~= nil and target.components.inventoryitem ~= nil and target.components.fueled:GetPercent()) or
            (target.components.armor ~= nil and target.components.inventoryitem ~= nil and target.components.armor:GetPercent()) or
            1
        ) / recipe.numtogive

        for k, ingredient in pairs(GetRecipeIngredients(recipe)) do
            if IsGemCoreModEnabled() and ingredient.signature ~= nil
            and (string.sub(GetIngredientPrefab(ingredient), -3) ~= "gem" or string.sub(GetIngredientPrefab(ingredient), -11, -4) == "precious") then
                local amt = math.max(1, math.ceil(ingredient.amount * ingredient_percent))
                for n = 1, amt do
                    SpawnLootPrefab(target, GetIngredientPrefab(ingredient))
                end
            end
        end

        Originaldestroystructure(staff, target)
    end
end

AddPrefabPostInit("greenstaff", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    if inst.components.spellcaster ~= nil then
        if Originaldestroystructure == nil then
            Originaldestroystructure = UpvalueHacker.GetUpvalue(Prefabs.greenstaff.fn, "destroystructure")
            SpawnLootPrefab = UpvalueHacker.GetUpvalue(Prefabs.greenstaff.fn, "destroystructure", "SpawnLootPrefab")
        end

        inst.components.spellcaster:SetSpellFn(destroystructure)
        UpvalueHacker.SetUpvalue(Prefabs.greenstaff.fn, destroystructure, "onhauntgreen", "destroystructure")
    end
end)
