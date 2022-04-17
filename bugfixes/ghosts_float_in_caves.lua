-- Imports
local COLLISION = GLOBAL.COLLISION
local ChangeToCharacterPhysics = GLOBAL.ChangeToCharacterPhysics

local function OnBecomeGhost(inst, data)
    -- Adjust collision to walk through water and cliffs in caves
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function OnRespawn(inst)
    -- Reset collision to player default
    ChangeToCharacterPhysics(inst)
end

local function OnSpawn(inst, player)
    if player ~= nil and player:HasTag("playerghost") then
        OnBecomeGhost(player)
    end
end

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
      
        -- Listen to ghost events
        inst:ListenForEvent("makeplayerghost", OnBecomeGhost)
        inst:ListenForEvent("respawnfromghost", OnRespawn)
  
    end
end)

-- World events
AddSimPostInit(function()

    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- On spawn - check if we need to apply the ghost mask
    GLOBAL.TheWorld:ListenForEvent("ms_playerjoined", OnSpawn)

end)
