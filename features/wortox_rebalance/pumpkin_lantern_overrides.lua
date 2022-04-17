-- Imports
local TUNING = GLOBAL.TUNING
local AllRecipes = GLOBAL.AllRecipes
local SPECIAL_EVENTS = GLOBAL.SPECIAL_EVENTS

-- Set a builder tag to make the recipe unavailable
local pumpkinlanternRecipe = AllRecipes["pumpkin_lantern"]
if pumpkinlanternRecipe ~= nil then
  pumpkinlanternRecipe.builder_tag = RECIPE_UNAVAILABLE
end

AddPrefabPostInit("pumpkin_lantern", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
      return
    end

    -- Add a sanity aura
    if inst.components.sanityaura ~= nil then
        inst:RemoveComponent("sanityaura")
    end
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY

    -- If not hallowed nights event, make unperishable
    if not GLOBAL.IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
        if inst.components.perishable ~= nil then
          inst.components.perishable.StartPerishing = function() end
          inst.components.perishable:StopPerishing()
          inst:AddTag("hide_percentage")
        end
    end
end)
