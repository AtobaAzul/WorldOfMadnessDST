-- Imports
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
modimport("features/weapon_degradation/constants.lua")

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
      
        local originalCalcDamageFn = inst.components.combat.CalcDamage
        function inst.components.combat:CalcDamage(target, weapon, multiplier)
            local damageMult = 1

            -- Get equipped weapon
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if item ~= nil and item.components.weapon ~= nil and item.components.finiteuses ~= nil then
                local weapon_degradation = item.components.finiteuses:GetPercent()

                if TableContains(WEAPON_GLASS_WEAPONS, item.prefab) then
                    damageMult = 1 - WEAPON_DEGRADATION_THRESHOLD
                end

                if (weapon_degradation <= WEAPON_DEGRADATION_THRESHOLD) then
                    if TableContains(WEAPON_GLASS_WEAPONS, item.prefab) then
                        damageMult = 1 - weapon_degradation
                    else
                        damageMult = weapon_degradation + (1 - WEAPON_DEGRADATION_THRESHOLD)
                    end
                end
            end

            return originalCalcDamageFn(self, target, weapon, multiplier * damageMult)
        end

    end
end)
