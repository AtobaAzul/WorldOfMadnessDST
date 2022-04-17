-- Imports
local json = GLOBAL.json
local TUNING = GLOBAL.TUNING
local AllPlayers = GLOBAL.AllPlayers
local WorldRollbackFromSim = GLOBAL.WorldRollbackFromSim

-- Register a network event
local function DoRollbackPenalty(sender_shard_id)
    for i, player in ipairs(AllPlayers) do
        if player ~= nil and player.components.inventory ~= nil then

            for k = 1, player.components.inventory.maxslots do
                local v = player.components.inventory.itemslots[k]
                if v ~= nil then
                    local item = player.components.inventory:DropItem(v, true, true)
                    if item ~= nil and item.components.burnable ~= nil then
                        player:DoTaskInTime(0.5, function()
                            item.components.burnable:Ignite()
                        end)
                    end
                end
            end
        
            for k, v in pairs(player.components.inventory.equipslots) do
                local item = player.components.inventory:DropItem(v, true, true)
                if item ~= nil and item.components.burnable ~= nil then
                    player:DoTaskInTime(0.5, function()
                        item.components.burnable:Ignite()
                    end)
                end
            end
    
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_rollback_penalty", DoRollbackPenalty)


local _WorldRollbackFromSim = WorldRollbackFromSim
GLOBAL.WorldRollbackFromSim = function(count)
    if TUNING.MADNESS.allow_rollback == nil or not TUNING.MADNESS.allow_rollback then
        GLOBAL.TheNet:Announce("󰀕 Your items have rolled back out of your pockets and have caught fire !", nil, nil, "none")
        SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_penalty"), nil)
    else
        -- Check whether the rollback cost an atrium world protection
        if GetModConfigData("MadnessWorldResets") == true then
            -- Imports
            modimport("features/madness_world_resets/constants.lua")

            GLOBAL.TheSim:CheckPersistentStringExists("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME, function(exists)
                if exists == true then
                    count = WORLD_RESET_ATRIUM_ROLLBACK_DAYS
                    GLOBAL.TheSim:SetPersistentString("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME, json.encode({rolling_back = true}), true)
                end
            end)
        end

        _WorldRollbackFromSim(count)
    end    
end
