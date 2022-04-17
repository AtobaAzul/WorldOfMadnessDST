-- Imports
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local SpawnPrefab = GLOBAL.SpawnPrefab
modimport("features/combat_overhaul_attack_speed/constants.lua")

-- Balance the Deconstruction Staff
local function deconstructionStaffOnAttack(inst, player)
    if inst ~= nil and inst.components.finiteuses ~= nil and player ~= nil and player.components.sanity ~= nil then
        player.components.sanity:SetPercent(math.max(0, player.components.sanity:GetPercent() - COMBAT_OVERHAUL_DECONSTRUCTION_ATTACK_COST))
        inst.components.finiteuses:SetPercent(math.max(0, inst.components.finiteuses:GetPercent() - COMBAT_OVERHAUL_DECONSTRUCTION_ATTACK_COST))
        if inst.components.finiteuses:GetPercent() <= 0 then
            SpawnPrefab("small_puff").Transform:SetPosition(player.Transform:GetWorldPosition())
            inst:Remove()
        else
            -- Undo original mod use cost
            player:DoTaskInTime(35/30, function(player)
                if player ~= nil and player.components.sanity ~= nil then
                    player.components.sanity:DoDelta(5)
                end
            end)
        end
    end
end

-- Balance the Bernie Shadow Scarer
local function bernieOnAttack(inst, player)
    if inst ~= nil and inst.components.fueled ~= nil and player ~= nil then
        inst.components.fueled:SetPercent(math.max(0, inst.components.fueled:GetPercent() - COMBAT_OVERHAUL_BERNIE_ATTACK_COST))
        if inst.components.fueled:GetPercent() <= 0 then
            if inst.components.lootdropper == nil then
                inst:AddComponent("lootdropper")
            end
            inst.components.lootdropper:SpawnLootPrefab("beardhair")
            inst.components.lootdropper:SpawnLootPrefab("beefalowool")
            inst.components.lootdropper:SpawnLootPrefab("silk")
            SpawnPrefab("small_puff").Transform:SetPosition(player.Transform:GetWorldPosition())
            inst:Remove()
        end
    end
end

-- Overall Player-Prefab-related Game Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
  
    if inst ~= nil and inst.components.combat ~= nil then
        inst.components.combat.min_attack_period = COMBAT_OVERHAUL_ATTACK_SPEED

        if inst.components.inventory ~= nil then

            local originalStartAttack = inst.components.combat.StartAttack
            function inst.components.combat:StartAttack()
                local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equip ~= nil and inst.components.combat.target ~= nil then

                    if equip:HasTag("bernie") and inst.components.combat.target:HasTag("shadow") then
                        bernieOnAttack(equip, inst)
                    end

                    if equip:HasTag("deconstructor") then
                        deconstructionStaffOnAttack(equip, inst)
                    end

                end
                originalStartAttack(self)
            end

        end
    end
end)
