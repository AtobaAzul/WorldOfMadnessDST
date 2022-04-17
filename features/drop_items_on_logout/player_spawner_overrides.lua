-- Imports
local TUNING = GLOBAL.TUNING

local function dropItems(inst, player)
    if player and player.components.inventory then

        -- Held item
        if player.components.inventory.activeitem ~= nil and not IsPlayerStarterItem(player.prefab, player.components.inventory.activeitem.prefab) then
            player.components.inventory:DropItem(player.components.inventory.activeitem)
            player.components.inventory:SetActiveItem(nil)
        end

        -- Inventory
        for k = 1, player.components.inventory.maxslots do
            local v = player.components.inventory.itemslots[k]
            if v ~= nil and not IsPlayerStarterItem(player.prefab, v.prefab) then
                player.components.inventory:DropItem(v, true, true)
            end
        end

        -- Equip slots
        for k, v in pairs(player.components.inventory.equipslots) do
            if v ~= nil and not IsPlayerStarterItem(player.prefab, v.prefab) then
                player.components.inventory:DropItem(v, true, true)
            end
        end

        -- Woby
        if player.woby ~= nil and player.woby.components.container ~= nil then
            player.woby.components.container:Close()

            for i = 1, player.woby.components.container.numslots do
                local item = player.woby.components.container.slots[i]
                if item ~= nil and item.components.inventoryitem ~= nil and not IsPlayerStarterItem(player.prefab, item.prefab) then
                    player.woby.components.container:DropItemBySlot(i)
                end
            end
        end

    end
end

-- Hook into the Player Spawner component
AddComponentPostInit("playerspawner", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Capture despawn events
    self.inst:ListenForEvent("ms_playerdespawn", dropItems)
    self.inst:ListenForEvent("ms_playerdespawnanddelete", dropItems)
end)
