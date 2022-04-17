-- Imports
modimport("features/global_combat_damage/constants.lua")

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
      
      -- Damage Section -----------------------------------------------------------------------------------------------------------------
      -- Damage to others modifier
      local originalCalcDamageFn = inst.components.combat.CalcDamage
      function inst.components.combat:CalcDamage(target, weapon, multiplier)
        -- Global server difficulty debuff
        local damageMult = GLOBAL_DAMAGE_TO_OTHERS_MULT
  
        if target ~= nil then
          -- Sanity debuff
          if inst.components.sanity ~= nil and inst.components.sanity:GetPercent() <= LOW_SANITY_THRESHOLD then
            damageMult = damageMult * LOW_SANITY_DAMAGE_TO_OTHERS_MULT
          end

          -- Hunger debuff
          if inst.components.hunger ~= nil and inst.components.hunger:GetPercent() <= LOW_HUNGER_THRESHOLD then
            damageMult = damageMult * LOW_HUNGER_DAMAGE_TO_OTHERS_MULT
          end
  
          -- Damage to shadow creatures
          if inst.components.sanity:GetPercent() >= DAMAGE_TO_SHADOW_CREATURES_BUFF_THRESHOLD and IsShadowCreature(target.prefab) then
            damageMult = damageMult * DAMAGE_TO_SHADOW_CREATURES_BUFF_MULT
          end
        end

        return originalCalcDamageFn(self, target, weapon, multiplier * damageMult)
      end
  
      -- Damage taken from things modifier
      local originalHealthDoDelta = inst.components.health.DoDelta
      function inst.components.health:DoDelta(amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
        local damageMult = 1
  
        -- Increase damage taken from monsters
        if amount ~= nil and afflicter ~= nil and amount < 0 then
          if afflicter:HasTag("monster") or afflicter:HasTag("shadowcreature") then
  
            -- Global server difficulty debuff
            damageMult = damageMult * GLOBAL_DAMAGE_DONE_TO_PLAYERS_MULT

            -- Sanity Debuff
            if inst.components.sanity ~= nil and inst.components.sanity:GetPercent() <= LOW_SANITY_THRESHOLD then
              damageMult = damageMult * LOW_SANITY_DAMAGE_DONE_TO_PLAYERS_MULT
            end

            -- Hunger Debuff
            if inst.components.hunger ~= nil and inst.components.hunger:GetPercent() <= LOW_HUNGER_THRESHOLD then
              damageMult = damageMult * LOW_HUNGER_DAMAGE_DONE_TO_PLAYERS_MULT
            end
  
          end
        end
        
        return originalHealthDoDelta(self, amount * damageMult, overtime, cause, ignore_invincible, afflicter, ignore_absorb)
      end
  
    end
end)
