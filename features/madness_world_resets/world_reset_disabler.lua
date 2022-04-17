-- Imports
local TUNING = GLOBAL.TUNING
local GetResetTime = GLOBAL.GetResetTime

-- Needs to be networked to the master shard
local function SetShardResetTime(sender_shard_id, reset_time)
    -- Only works if run on master shard
    if IsMasterShard() then
        if reset_time ~= nil then
            GLOBAL.TheWorld:PushEvent("ms_setworldresettime", { time = reset_time, loadingtime = reset_time })
        else
            GLOBAL.TheWorld:PushEvent("ms_setworldresettime", GetResetTime(GLOBAL.TheNet:GetServerGameMode()))
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_reset_timer_settime", SetShardResetTime)

function SetResetTime(reset_time)
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_reset_timer_settime"), nil, reset_time)
end

local function ToggleResetTimers(sender_shard_id, madness_ghost_count)
    -- Update on all shards
    TUNING.MADNESS.world_reset_ghost_count = madness_ghost_count
    GLOBAL.TheWorld:PushEvent("madness_world_reset_update", {state = madness_ghost_count})

    if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.shard ~= nil and GLOBAL.TheWorld.shard.components.shard_players ~= nil then
        local ghost_count = GLOBAL.TheWorld.shard.components.shard_players:GetNumGhosts()
        if madness_ghost_count ~= nil then
            ghost_count = madness_ghost_count
        end

        GLOBAL.TheWorld:PushEvent("ms_playercounts",
        {
            total = GLOBAL.TheWorld.shard.components.shard_players:GetNumPlayers(),
            ghosts = ghost_count,
            alive = GLOBAL.TheWorld.shard.components.shard_players:GetNumAlive()
        })
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_reset_timer_toggle", ToggleResetTimers)

local function OnWorldResetTriggered()
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_reset_timer_toggle"), nil, TUNING.MADNESS.world_reset_ghost_count)
end

local function OnWorldResetTriggeredShowDialog(inst)
    if not TUNING.MADNESS.world_reset_dialog_shown then
        TUNING.MADNESS.world_reset_dialog_shown = true
        OnWorldResetTriggered()
    end
end

local function OnWorldResetTriggeredHideDialog(inst)
    if TUNING.MADNESS.world_reset_dialog_shown then
        TUNING.MADNESS.world_reset_dialog_shown = false
        OnWorldResetTriggered()
    end
end

local function StartDoomEffects()
    SetResetTime(240) -- 4 minutes (1/2 a day)
    if GLOBAL.TheWorld.worldprefab == "forest" then
        PlayNetworkedSound("final_hours", "madness_sounds/madness_world_reset/final_hours")
    else
        PlayNetworkedSound("final_hours", "madness_sounds/madness_world_reset/final_hours_caves")
    end
end

local function StopDoomEffects()
    SetResetTime()
    StopNetworkedSound("final_hours")
    StopEarthquakes()
end

local function SetGhostCountAndUpdate(ghost_count)
    TUNING.MADNESS.world_reset_ghost_count = ghost_count
    OnWorldResetTriggered()
end

function IsWorldResetDisabled()
    return (TUNING.MADNESS.world_reset_ghost_count == 0)
end

function IsWorldResetForced()
    return (TUNING.MADNESS.world_reset_ghost_count == 1)
end

function ForceWorldReset()
    StartDoomEffects()
    SetGhostCountAndUpdate(1)
end

function DisableWorldReset()
    StopDoomEffects()
    SetGhostCountAndUpdate(0)
end

function RestoreWorldReset()
    StopDoomEffects()
    SetGhostCountAndUpdate()
end

-- World events
AddSimPostInit(function()

    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- The following must only trigger on the master shard
    if IsMasterShard() then
        -- Capture World Reset Countdown events
        -- "hideworldreset" event is somehow sent at each tick so this hack is required to avoid a memory overflow
        GLOBAL.TheWorld:ListenForEvent("showworldreset", OnWorldResetTriggeredShowDialog)
        GLOBAL.TheWorld:ListenForEvent("hideworldreset", OnWorldResetTriggeredHideDialog)
    end

end)
