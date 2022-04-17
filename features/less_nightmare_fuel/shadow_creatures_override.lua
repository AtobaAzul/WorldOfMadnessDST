-- Imports
local FindPlayersInRange = GLOBAL.FindPlayersInRange
modimport("features/less_nightmare_fuel/constants.lua")

-- Characters who still cause nightmare fuel to drop
local function CausesNightmarefuelToDrop(player)
  if player ~= nil and player.prefab ~= nil then

      for k, v in pairs(NIGHTMAREFUEL_INCREASE_DROP_CHARACTERS) do
          if v == player.prefab then
              return true
          end
      end
      
      return false
  end

  -- Nil object passed, return false
  return false
end

-- Decrease/remove nightmare fuel drop
local function adjustShadowCreatureNightmareFuelDrop(inst, chance)
    if inst == nil or inst.components == nil or inst.components.lootdropper == nil then
      return
    end
  
    local originalGenerateLootFunction = inst.components.lootdropper.GenerateLoot
    function inst.components.lootdropper:GenerateLoot()
      local loots = originalGenerateLootFunction(self)

      local chanceBonusApplied = false
      local x, y, z = inst.Transform:GetWorldPosition()
      local players = FindPlayersInRange(x, y, z, NIGHTMAREFUEL_INCREASE_DROP_RANGE, true)

      for i, player in ipairs(players) do
        if player ~= nil and not chanceBonusApplied and CausesNightmarefuelToDrop(player) then
          chance = chance + NIGHTMAREFUEL_INCREASE_DROP_CHANCE_BONUS
          chanceBonusApplied = true
        end
      end

      local adjustedLoots = {}
      for i, v in ipairs(loots) do
        if v ~= "nightmarefuel" or math.random() < chance then
          table.insert(adjustedLoots, v)
        end
      end
  
      return adjustedLoots
    end
end

-- Decrease chance from beardlings
AddPrefabPostInit("rabbit", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end

    adjustShadowCreatureNightmareFuelDrop(inst, RABBIT_NIGHTMARE_FUEL_CHANCE)
end)

-- Shadow Creatures Remove Nightmare Fuel Drop
local function RemoveNightmareFuelDrop(prefab)
  AddPrefabPostInit(prefab, function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
      return
    end

    adjustShadowCreatureNightmareFuelDrop(inst, SHADOW_CREATURES_NIGHTMARE_FUEL_CHANCE)
  end)
end

for k, v in pairs(SHADOW_CREATURES) do
	RemoveNightmareFuelDrop(v)
end
