-- Imports
local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
modimport("features/weapon_degradation/constants.lua")

-- Add a fueling-like action to repair the item
local function RepairAction(act)
    if act.doer.components.inventory then

        if act.invobject ~= nil and act.target ~= nil and act.invobject.components.finiteuses ~= nil and act.target.components.finiteuses ~= nil and act.invobject.prefab == act.target.prefab then
            local bestItemDurability = math.max(act.invobject.components.finiteuses:GetPercent(), act.target.components.finiteuses:GetPercent())
            local worstItemDurability = math.min(act.invobject.components.finiteuses:GetPercent(), act.target.components.finiteuses:GetPercent())

            local repairAmount = math.clamp(worstItemDurability / 2, WEAPON_REPAIR_MIN_PERCENT, WEAPON_REPAIR_MAX_PERCENT)
            if bestItemDurability + repairAmount > 1 then
                repairAmount = 1 - bestItemDurability
            end
            
            act.doer.components.inventory:RemoveItem(act.invobject)
            act.target.components.finiteuses:SetPercent(bestItemDurability + repairAmount)
            return true
        end

    end
end

local function RepairClientAction(inst, doer, target, actions, right)
    if target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer) then

        if inst.prefab == target.prefab then
            table.insert(actions, ACTIONS.REPAIR_WEAPON)
        end

    end
end

local REPAIR_WEAPON = Action({priority=10, mount_valid=true})
REPAIR_WEAPON.str = "Repair"
REPAIR_WEAPON.id = "REPAIR_WEAPON"
REPAIR_WEAPON.fn = RepairAction
AddAction(REPAIR_WEAPON)
AddComponentAction("USEITEM", "weapon", RepairClientAction)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REPAIR_WEAPON, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REPAIR_WEAPON, "doshortaction"))
