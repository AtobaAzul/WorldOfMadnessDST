-- Imports
local FindPlayersInRange = GLOBAL.FindPlayersInRange
modimport("features/global_combat_damage/constants.lua")

-- Shadow Creatures Sanity Buff When Defeated
local function onKillShadowCreature(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 30, true)
    for i, player in ipairs(players) do
      if player ~= nil and player.components.sanity ~= nil then

        if player.components.sanity:GetPercent() <= SHADOW_CREATURES_SANITY_BUFF_THRESHOLD then
          -- Check whether this passes the max allowed
          if (player.components.sanity.current + SHADOW_CREATURES_SANITY_BUFF_AMOUNT) / player.components.sanity.max > SHADOW_CREATURES_SANITY_BUFF_MAX_PERCENT then
            player.components.sanity:DoDelta((SHADOW_CREATURES_SANITY_BUFF_MAX_PERCENT * player.components.sanity.max) - player.components.sanity.current)
          else
            player.components.sanity:DoDelta(SHADOW_CREATURES_SANITY_BUFF_AMOUNT)
          end
        end
        
      end
    end
end

local function ApplyMaxHealthAndSanityBuffOnDefeat(prefab)
    AddPrefabPostInit(prefab, function(inst)
      if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
      end

      -- Creeping Fears have WAY too much health considering the damage reduction debuff when insane...
      if prefab == "creepingfear" then
        inst.components.health:SetMaxHealth(SHADOW_CREATURES_CREEPINGFEAR_HEALTH)
      end

      inst.components.health:SetMaxHealth( math.min(inst.components.health:GetMaxWithPenalty(), SHADOW_CREATURES_MAX_HEALTH) )
      inst.components.combat.onkilledbyother = onKillShadowCreature
    end)
end
  
for k, v in pairs(SHADOW_CREATURES) do
    ApplyMaxHealthAndSanityBuffOnDefeat(v)
end
