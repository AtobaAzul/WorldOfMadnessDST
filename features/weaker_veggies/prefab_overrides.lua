-- Imports
local FOODTYPE = GLOBAL.FOODTYPE
modimport("features/weaker_veggies/constants.lua")

AddPrefabPostInitAny(function(inst)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Check if a cookable veggie
    if inst.components.edible ~= nil and inst.components.edible.hungervalue ~= nil
    and inst.components.edible.foodtype == FOODTYPE.VEGGIE and inst:HasTag("cookable") then

        -- Reduce Hunger Value
        inst.components.edible.hungervalue = math.max(inst.components.edible.hungervalue * WEAKER_VEGGIES_MULTIPLIER, WEAKER_VEGGIES_MIN_CALORIES)
        
    end
end)
