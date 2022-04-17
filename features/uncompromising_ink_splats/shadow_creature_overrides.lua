-- Imports
local FindPlayersInRange = GLOBAL.FindPlayersInRange

local function OnGooRemoved(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 1, true)

    for i, player in ipairs(players) do
        if player ~= nil and not player:HasTag("playerghost") and not player:HasTag("shadowdominant")
        and player.components.inkable ~= nil and (player.components.inkable.inked == nil or not player.components.inkable.inked) then
            player.components.inkable:Ink()
        end
    end
end

-- Capture OnRemove to capture when the projectile lands or collides with something
AddPrefabPostInit(
  "shadow_goo",
  function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end

    if inst ~= nil then
      inst:ListenForEvent("onremove", OnGooRemoved)
    end
end)
