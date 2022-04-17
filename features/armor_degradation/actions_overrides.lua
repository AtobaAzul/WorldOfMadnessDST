-- Imports
local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS
local ActionHandler = GLOBAL.ActionHandler
modimport("features/armor_degradation/constants.lua")

-- Add a fueling-like action to repair the item
local function RepairAction(act)
    if act.doer.components.inventory then

        if act.invobject ~= nil and act.target ~= nil and act.invobject.components.armor ~= nil and act.target.components.armor ~= nil and act.invobject.prefab == act.target.prefab then
            local bestItemDurability = math.max(act.invobject.components.armor:GetPercent(), act.target.components.armor:GetPercent())
            local worstItemDurability = math.min(act.invobject.components.armor:GetPercent(), act.target.components.armor:GetPercent())

            local repairAmount = math.clamp(worstItemDurability / 2, ARMOR_REPAIR_MIN_PERCENT, ARMOR_REPAIR_MAX_PERCENT)
            if bestItemDurability + repairAmount > 1 then
                repairAmount = 1 - bestItemDurability
            end
            
            act.doer.components.inventory:RemoveItem(act.invobject)
            act.target.components.armor:SetPercent(bestItemDurability + repairAmount)
            return true
        end

    end
end

local function RepairClientAction(inst, doer, target, actions, right)
    if target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer) then

        if inst.prefab == target.prefab then
            table.insert(actions, ACTIONS.REPAIR_ARMOR)
        end

    end
end

local REPAIR_ARMOR = Action({priority=10, mount_valid=true})
REPAIR_ARMOR.str = "Repair"
REPAIR_ARMOR.id = "REPAIR_ARMOR"
REPAIR_ARMOR.fn = RepairAction
AddAction(REPAIR_ARMOR)
AddComponentAction("USEITEM", "armor", RepairClientAction)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.REPAIR_ARMOR, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.REPAIR_ARMOR, "doshortaction"))
