-- Imports
local json = GLOBAL.json
local TUNING = GLOBAL.TUNING
modimport("features/madness_world_resets/constants.lua")

-- Save Atrium Gate instance if the shard is hosting the gate
local atrium_instance = nil
local moon_instance = nil

local returning_from_rollback = false

local function ShardPowerOnAtrium(sender_shard_id, moon)
    local inst = atrium_instance
    if inst == nil then inst = moon_instance end
    if not moon then moon = nil end

    if inst ~= nil then
        if (moon ~= nil and inst.prefab == "moon_altar") or (moon == nil and inst.prefab == "atrium_gate") then
            inst.madness_powered = true

            if inst.madness_protection_days_left == nil then
                if inst.prefab == "atrium_gate" then
                    inst.madness_protection_days_left = WORLD_RESET_ATRIUM_PROTECTION_DAYS
                elseif inst.prefab == "moon_altar" then
                    inst.madness_protection_days_left = WORLD_RESET_MOONALTAR_PROTECTION_DAYS
                end
            end
            
            if inst.prefab == "atrium_gate" then
                GLOBAL.TheWorld:PushEvent("atriumpowered", true)
                GLOBAL.TheWorld:PushEvent("ms_locknightmarephase", "wild")
            end
        end
    end

    -- Rollback enabled if cave atrium is activated
    -- Must execute on all shards
    if moon == nil and GetModConfigData("PenaltyOnRollback") == true then
        TUNING.MADNESS.allow_rollback = true
        if IsMasterShard() then
            GLOBAL.TheSim:SetPersistentString("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME, json.encode({rolling_back = false}), true)
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_reset_timer_poweron_atrium", ShardPowerOnAtrium)

function PowerOnAtrium(silent, moon)
    if silent == nil or not silent then
        local announceString = "An ancient magic aura protects the world from certain doom... for now."
        GLOBAL.TheNet:Announce("󰀛 " .. announceString, nil, nil, "none")
        GLOBAL.TheWorld:PushEvent("madness_world_reset_atrium", {announcement = announceString})
    end
    DisableWorldReset()
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_reset_timer_poweron_atrium"), nil, moon)
end

local function ShardPowerOffAtrium(sender_shard_id, moon)
    local inst = atrium_instance
    if inst == nil then inst = moon_instance end
    if not moon then moon = nil end

    if inst ~= nil then
        if (moon ~= nil and inst.prefab == "moon_altar") or (moon == nil and inst.prefab == "atrium_gate") then
            inst.madness_powered = false
            inst.madness_protection_days_left = nil

            if inst.prefab == "atrium_gate" then
                GLOBAL.TheWorld:PushEvent("atriumpowered", false)
                GLOBAL.TheWorld:PushEvent("ms_locknightmarephase", nil)
            end
        end
    end

    -- Rollback disabled if atrium is deactivated
    -- Must execute on all shards
    if moon == nil and GetModConfigData("PenaltyOnRollback") == true then
        returning_from_rollback = false
        TUNING.MADNESS.allow_rollback = false
        if IsMasterShard() then
            GLOBAL.TheSim:ErasePersistentString("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME)
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_reset_timer_poweroff_atrium", ShardPowerOffAtrium)

function PowerOffAtrium(silent, moon)
    if silent == nil or not silent then
        local announceString = "The ancient protective magic surrounding the world has withered away..."
        GLOBAL.TheNet:Announce("󰀛 " .. announceString, nil, nil, "none")
        GLOBAL.TheWorld:PushEvent("madness_world_reset_atrium", {announcement = announceString})
    end
    RestoreWorldReset()
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_reset_timer_poweroff_atrium"), nil, moon)
end

function PowerOffAllAtriums(silent)
    PowerOffAtrium(silent, true)
    PowerOffAtrium(silent)
end

local function ShardSetIsReturningFromRollback(sender_shard_id, retval)
    returning_from_rollback = retval
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_rollback_set_returning", ShardSetIsReturningFromRollback)

local function ShardGetIsReturningFromRollback(sender_shard_id)
    -- The file only exists on the master shard
    if IsMasterShard() then

        -- Check if a rollback was used in exchange for atrium protection
        local retval = false
        GLOBAL.TheSim:CheckPersistentStringExists("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME, function(exists)
            if exists == true then
                GLOBAL.TheSim:GetPersistentString("../" .. WORLD_RESET_ATRIUM_ROLLBACK_FILENAME, function(load_success, json_data)
                    if load_success == true then
                        local data = json.decode(json_data)
                        if data and data.rolling_back and data.rolling_back == true then
                            retval = true
                        end
                    end
                end)
            end
        end)

        SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_set_returning"), nil, retval)

    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_rollback_get_returning", ShardGetIsReturningFromRollback)

local function GetIsReturningFromRollback()
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_get_returning"), nil)
end

local function MakeTradable(prefab)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim or inst == nil then
            return
        end
    
        if inst.components.tradable == nil then
            inst:AddComponent("tradable")
        end
    end)
end

MakeTradable(WORLD_RESET_ATRIUM_PROTECTION_ITEM)
MakeTradable(WORLD_RESET_MOONALTAR_PROTECTION_ITEM)

-- Glommer Flower Extension
local function ShardRollbackGlommerFound(sender_shard_id, found)
    if found == true then
        TUNING.MADNESS.world_reset_glommer_extra_days = 20
    else
        TUNING.MADNESS.world_reset_glommer_extra_days = 0
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_rollback_glommer_found", ShardRollbackGlommerFound)

AddPrefabPostInit("statueglommer", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    -- Initialize
    inst.madness_glommer_found = false

    local originalOnSave = inst.OnSave
    local originalOnLoad = inst.OnLoad

    local function onsave(inst, data)
        originalOnSave(inst, data)
        data.madness_glommer_found = inst.madness_glommer_found
    end

    local function onload(inst, data)
        originalOnLoad(inst, data)

        if data ~= nil then 
            inst.madness_glommer_found = data.madness_glommer_found
        end

        SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_glommer_found"), nil, inst.madness_glommer_found)
    end

    inst.OnSave = onsave
    inst.OnLoad = onload

    if inst.components.pickable ~= nil and GLOBAL.TheWorld.state ~= nil and GLOBAL.TheWorld.state.cycles ~= nil then

        local originalOnPicked = inst.components.pickable.onpickedfn
        inst.components.pickable.onpickedfn = function(inst, picker, loot)
            originalOnPicked(inst, picker, loot)

            inst.madness_glommer_found = true
            SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_glommer_found"), nil, inst.madness_glommer_found)

            local day = GLOBAL.TheWorld.state.cycles + 1
            if day == 11 then
                GLOBAL.TheNet:Announce("󰀛 The ancient flower radiates energy that keeps evil at bay... for now.", nil, nil, "none")
                GLOBAL.TheWorld:PushEvent("madness_world_reset_glommer")
            end
        end

    end
end)

-- For the overworld version
AddPrefabPostInit("moon_altar", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    -- Initialize
    moon_instance = inst
    inst.madness_powered = false
    inst.madness_protection_days_left = nil
    inst:AddTag("gemsocket")

    local originalOnSave = inst.OnSave
    local originalOnLoad = inst.OnLoad

    local function onsave(inst, data)
        originalOnSave(inst, data)
        data.madness_powered = inst.madness_powered
        data.madness_protection_days_left = inst.madness_protection_days_left
    end

    local function onload(inst, data)
        originalOnLoad(inst, data)

        if data ~= nil then 
            inst.madness_powered = data.madness_powered
            inst.madness_protection_days_left = data.madness_protection_days_left
        end

        inst:DoTaskInTime(5, function(inst)
            GetIsReturningFromRollback()
        end)

        inst:DoTaskInTime(10, function(inst)
            if inst.madness_powered == true then
                if GetModConfigData("PenaltyOnRollback") == true and returning_from_rollback == true then
                    print("[MADNESS] Moon: All Atriums Off")
                    PowerOffAllAtriums(true)
                else
                    print("[MADNESS] Moon Atrium On")
                    PowerOnAtrium(true, true)
                end
            else
                if GetModConfigData("PenaltyOnRollback") == true and returning_from_rollback == true then
                    print("[MADNESS] Moon Atrium Off")
                    PowerOffAtrium(true, true)
                end
            end
        end)
    end

    local function onremove(inst)
        PowerOffAtrium(false, true)
    end

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnRemoveEntity = onremove

    if inst.components.trader == nil then
        inst:AddComponent("trader")
    end
    
    inst.components.trader:SetAbleToAcceptTest(function(inst, item)
        if not IsWorldResetDisabled() and inst.components.inspectable ~= nil and inst.components.inspectable:GetStatus() ~= "MOON_ALTAR_WIP"
        and item ~= nil and item.prefab ~= nil and item.prefab == WORLD_RESET_MOONALTAR_PROTECTION_ITEM then
            return true
        end

        return false
    end)

    inst.components.trader.onaccept = function(inst, giver)
        if not IsWorldResetDisabled() then
            PowerOnAtrium(false, true)
        end
    end

    inst.components.trader.deleteitemonaccept = true
end)

local function unlockFences(inst, ispowered)
    inst:DoTaskInTime(1, function(inst)
        if IsWorldResetDisabled() then
            inst.locked = false
        end
    end)
end

AddPrefabPostInit("atrium_fence", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    inst:ListenForEvent("atriumpowered", function(_, ispowered) unlockFences(inst, ispowered) end, GLOBAL.TheWorld)
end)

AddPrefabPostInit("atrium_gate", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    -- Initialize
    atrium_instance = inst
    inst.madness_powered = false
    inst.madness_protection_days_left = nil

    local originalOnRemove = inst.OnRemoveEntity

    local function onsave(inst, data)
        data.madness_powered = inst.madness_powered
        data.madness_protection_days_left = inst.madness_protection_days_left
    end

    local function onload(inst, data)
        if data ~= nil then 
            inst.madness_powered = data.madness_powered
            inst.madness_protection_days_left = data.madness_protection_days_left
        end

        inst:DoTaskInTime(5, function(inst)
            GetIsReturningFromRollback()
        end)

        inst:DoTaskInTime(10, function(inst)
            if inst.madness_powered == true then
                if GetModConfigData("PenaltyOnRollback") == true and returning_from_rollback == true then
                    print("[MADNESS] Cave: All Atriums Off")
                    PowerOffAllAtriums(true)
                else
                    print("[MADNESS] Cave Atrium On")
                    PowerOnAtrium(true)
                end
            else
                if GetModConfigData("PenaltyOnRollback") == true and returning_from_rollback == true then
                    print("[MADNESS] Cave Atrium Off")
                    PowerOffAtrium(true)
                end
            end
        end)
    end

    local function onremove(inst)
        PowerOffAtrium()
        originalOnRemove(inst)
    end

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnRemoveEntity = onremove

    -- Make the gate accept moon rocks
    if inst.components.trader ~= nil and inst.components.inspectable ~= nil then

        local moonrockGiven = false

        local originalOnAcceptFn = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver)
            -- Check if the atrium is powered
            if not IsWorldResetDisabled() then
                if inst.components.inspectable:GetStatus() == "OFF" and moonrockGiven == true then
                    PowerOnAtrium()
                elseif not moonrockGiven then
                    originalOnAcceptFn(inst, giver)
                end
            end
        end

        local originalAcceptTestFn = inst.components.trader.abletoaccepttest
        inst.components.trader:SetAbleToAcceptTest(function(inst, item)
            -- Check if the atrium is powered
            if not IsWorldResetDisabled() then
                if item ~= nil and item.prefab ~= nil and item.prefab == WORLD_RESET_ATRIUM_PROTECTION_ITEM and inst.components.inspectable:GetStatus() == "OFF" then
                    moonrockGiven = true
                    return true
                end
            
                moonrockGiven = false
                return originalAcceptTestFn(inst, item)
            end

            return false
        end)

    end
end)

-- Register a network event
local function UseAndCheckProtectionDays(playerDeath)
    local dayCost = 1
    if playerDeath ~= nil and playerDeath == true then
        dayCost = WORLD_RESET_ATRIUM_DEATH_DAY_COST
    end

    if atrium_instance ~= nil and atrium_instance.madness_protection_days_left ~= nil then
        atrium_instance.madness_protection_days_left = atrium_instance.madness_protection_days_left - dayCost

        if atrium_instance.madness_protection_days_left <= 0 then
            PowerOffAtrium()
        end
    end

    if moon_instance ~= nil and moon_instance.madness_protection_days_left ~= nil then
        moon_instance.madness_protection_days_left = moon_instance.madness_protection_days_left - dayCost

        if moon_instance.madness_protection_days_left <= 0 then
            PowerOffAtrium(false, true)
        end
    end
end

local function ApplyPlayerDeathProtectionDaysPenalty(sender_shard_id)
    UseAndCheckProtectionDays(true)
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_reset_apply_day_penalty", ApplyPlayerDeathProtectionDaysPenalty)

-- On Player death
local function OnBecomeGhost(inst, data)
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_reset_apply_day_penalty"), nil)
end

-- On Cycle Change
local function OnCycleChange()
    UseAndCheckProtectionDays()
end

-- Player events
-- Needs to be networked, since players on other shards
-- may die and this needs to update the penalty cost
-- on all shards containing a powered atrium gate
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
  
    if inst ~= nil then
        inst:ListenForEvent("makeplayerghost", OnBecomeGhost)
    end
end)

-- World events
-- Does not need to be networked since only the shards
-- hosting the atrium gate will have their reset days left
-- not set to nil
AddSimPostInit(function()
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    GLOBAL.TheWorld:ListenForEvent("cycleschanged", OnCycleChange)
end)
