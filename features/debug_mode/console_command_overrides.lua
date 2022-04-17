-- Imports
local SuUsed = GLOBAL.SuUsed

-- Debug Functions
GLOBAL.CHEATS_ENABLED = true
GLOBAL.require('debugkeys')

-- Set very short seasons to test events
function c_setdebugseasons()
    SuUsed("c_setdebugseasons", true)

    GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season="autumn", length=1})
    GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season="winter", length=2})
    GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season="spring", length=1})
    GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season="summer", length=2})
    GLOBAL.TheWorld:PushEvent("ms_setseasonclocksegs",
    {   autumn={day=14,dusk=1,night=1},
        winter={day=14,dusk=1,night=1},
        spring={day=14,dusk=1,night=1},
        summer={day=14,dusk=1,night=1}
    })
end

-- Register as global command accessible from console
GLOBAL.c_setdebugseasons = c_setdebugseasons

local function Shard_c_nextday(sender_shard_id, phase)
    -- Only works if run on master shard
    if IsMasterShard() then
        if phase ~= nil and phase == true then
            GLOBAL.TheWorld:PushEvent("ms_nextphase")
        else
            GLOBAL.TheWorld:PushEvent("ms_nextcycle")
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_c_nextday", Shard_c_nextday)

function c_nextday(phase)
    SuUsed("c_nextday", true)

    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_c_nextday"), nil, phase)
end

-- Register as global command accessible from console
GLOBAL.c_nextday = c_nextday
