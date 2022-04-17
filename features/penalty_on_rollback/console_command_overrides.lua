-- Imports
local SuUsed = GLOBAL.SuUsed
local TUNING = GLOBAL.TUNING

-- Register a network event
local function UpdateRollbackEnableFlag(sender_shard_id, enableRollbackFlag)
    TUNING.MADNESS.allow_rollback = enableRollbackFlag
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_rollback_penalty_flag", UpdateRollbackEnableFlag)

-- Add a global function
function c_enablerollback()
    SuUsed("c_enablerollback", true)

    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_penalty_flag"), nil, true)
end

-- Register as global command accessible from console
GLOBAL.c_enablerollback = c_enablerollback


-- Add a global function
function c_disablerollback()
    SuUsed("c_disablerollback", true)

    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_rollback_penalty_flag"), nil, false)
end

-- Register as global command accessible from console
GLOBAL.c_disablerollback = c_disablerollback
