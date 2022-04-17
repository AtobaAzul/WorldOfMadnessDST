-- Imports
local SpawnPrefab = GLOBAL.SpawnPrefab

local function OnRespawn(inst)
    -- Check if it is night time, in the dark, or in caves
    if (inst ~= nil and inst.components.inventory ~= nil)
    and ((GLOBAL.TheWorld.worldprefab == "cave")
    or (GLOBAL.TheWorld.state.isnight)
    or (inst.LightWatcher ~= nil and not inst.LightWatcher:IsInLight())) then
        inst.components.inventory:GiveItem(SpawnPrefab("torch", "torch_shadow_alt", nil, inst.userid))
    end
end

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
  
    if inst ~= nil then
        inst:ListenForEvent("respawnfromghost", OnRespawn)
    end
end)
