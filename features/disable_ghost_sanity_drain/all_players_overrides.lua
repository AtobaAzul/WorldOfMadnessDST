-- Imports
local TUNING = GLOBAL.TUNING

-- Reduce sanity aura from ghosts
AddPrefabPostInit("ghost", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst ~= nil and inst.components.sanityaura ~= nil then
        inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
    end
end)

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
  
    if inst ~= nil and inst.components.sanity ~= nil then
        inst.components.sanity:SetPlayerGhostImmunity(true)
    end
end)
