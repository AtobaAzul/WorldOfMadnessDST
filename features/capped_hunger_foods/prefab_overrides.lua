-- Imports
modimport("features/capped_hunger_foods/constants.lua")

AddPrefabPostInitAny(function(inst)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Check if an edible with a hunger value
    if inst.components.edible ~= nil and inst.components.edible.hungervalue ~= nil then

        -- Cap Hunger Value
        inst.components.edible.hungervalue = math.min(inst.components.edible.hungervalue, CAP_HUNGER_FOODS_MAX_VALUE)
        
    end
end)
