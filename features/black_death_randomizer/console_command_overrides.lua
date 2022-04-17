-- Imports
local SuUsed = GLOBAL.SuUsed

-- Register a network event
local function ShardGetCure(sender_shard_id)
    if IsMasterShard() then
        local str = "The cure: "
        str = str .. tostring(GLOBAL.TheWorld.state.madness_cure_ingredient1) .. ", "
        str = str .. tostring(GLOBAL.TheWorld.state.madness_cure_ingredient2) .. ", "
        str = str .. tostring(GLOBAL.TheWorld.state.madness_cure_ingredient3) .. "."
        print(str)
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_getcure", ShardGetCure)

-- Add a global function
function c_getcure()
    SuUsed("c_getcure", true)

    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_getcure"), nil)
end

-- Register as global command accessible from console
GLOBAL.c_getcure = c_getcure
