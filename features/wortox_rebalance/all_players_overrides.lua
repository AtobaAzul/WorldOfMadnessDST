-- Imports
modimport("features/wortox_rebalance/constants.lua")

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
      
      -- Damage taken from things modifier
      local originalHealthDoDelta = inst.components.health.DoDelta
      function inst.components.health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        local damageMult = 1
  
        -- Reduce heals from Wortox Souls
        if cause ~= nil and cause == "wortox_soul" then
          damageMult = SOUL_HEAL_MULTIPLIER
        end
        return originalHealthDoDelta(self, amount * damageMult, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
      end
  
    end
end)
