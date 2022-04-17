-- Imports
local ProfileStatsAdd = GLOBAL.ProfileStatsAdd
modimport("features/armor_degradation/constants.lua")

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
  
      -- Armor Degradation
      if inst.components.inventory ~= nil then
  
        function inst.components.inventory:ApplyDamage(damage, attacker, weapon)
          --check resistance and specialised armor
          local absorbers = {}
          for k, v in pairs(self.equipslots) do
              if v.components.resistance ~= nil and
                v.components.resistance:HasResistance(attacker, weapon) and
                v.components.resistance:ShouldResistDamage() then
                v.components.resistance:ResistDamage(damage)
                return 0
              elseif v.components.armor ~= nil then
                -- Apply adjusted absorption depending on armor degradation status
                local degraded_absorption = v.components.armor:GetAbsorption(attacker, weapon)
                local armor_degradation = v.components.armor:GetPercent()
  
                if (armor_degradation <= ARMOR_DEGRADATION_THRESHOLD) then
                  degraded_absorption = degraded_absorption * (armor_degradation + (1 - ARMOR_DEGRADATION_THRESHOLD) )
                end
  
                absorbers[v.components.armor] = degraded_absorption
              end
          end
      
          -- Sort armor from highest absorption to lowest
          local total_absorption = 0
          local leftover_damage = damage
          table.sort(absorbers, function(a,b) return a > b end)
  
          -- Absorb damage
          for armor, amt in pairs(absorbers) do
            local absorbed_damage = leftover_damage * amt
            armor:TakeDamage(absorbed_damage + armor:GetBonusDamage(attacker, weapon))
  
            total_absorption = total_absorption + absorbed_damage
            leftover_damage = math.max(leftover_damage - absorbed_damage, 0)
          end
  
          if total_absorption > 0 then
              ProfileStatsAdd("armor_absorb", total_absorption)
          end
      
          return leftover_damage
        end
  
      end
  
    end
end)
