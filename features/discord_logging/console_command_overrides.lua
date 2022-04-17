-- Imports
local SuUsed = GLOBAL.SuUsed
local Vector3 = GLOBAL.Vector3
local FOODTYPE = GLOBAL.FOODTYPE
local FOODGROUP = GLOBAL.FOODGROUP
local AllPlayers = GLOBAL.AllPlayers
local SpawnPrefab = GLOBAL.SpawnPrefab
local PLAYERCOLOURS = GLOBAL.PLAYERCOLOURS
local Networking_Say = GLOBAL.Networking_Say
modimport("features/discord_logging/constants.lua")

-- Local Functions
function DoResurrection(player, cause)
    if player ~= nil then
        local data = {
            user = {}
        }
        data.user.GetDisplayName = function(self)
            return cause
        end
    
        player:PushEvent("respawnfromghost", data)
    end
end

local function CureVirus(player)
    if player ~= nil and player.components.tiddlevirus ~= nil then
        -- Cure FX
        local x, y, z = player.Transform:GetWorldPosition()
        local fx = SpawnPrefab("shadow_despawn")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end

        -- Cure Virus
        player.components.tiddlevirus:StopVirus()
    end
end

local function SpawnHealingSalves(player)
    local x, y, z = player.Transform:GetWorldPosition()

    for i = 1, 7 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("healingsalve", x, y, z)
        end)
    end
end

local function SpawnFood(player)
    local x, y, z = player.Transform:GetWorldPosition()
    local foodPrefab = "meat"

    if player.components.eater ~= nil and player.components.eater.caneat ~= nil and TableContains(player.components.eater.caneat, FOODGROUP.VEGETARIAN) then
        foodPrefab = "pumpkin"
    end

    if player.components.eater ~= nil and player.components.eater.preferseatingtags ~= nil and TableContains(player.components.eater.preferseatingtags, "preparedfood") then
        foodPrefab = "meatballs"
    end

    if player.prefab == "wortox" then
        foodPrefab = "wortox_soul_spawn"
    end

    for i = 1, 7 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect(foodPrefab, x, y, z)
        end)
    end
end

local function SpawnSanityHelp(player)
    local x, y, z = player.Transform:GetWorldPosition()
    local foodPrefab = "green_cap_cooked"

    if player.components.eater ~= nil and player.components.eater.preferseating ~= nil and TableContains(player.components.eater.preferseating, FOODTYPE.MEAT) then
        foodPrefab = "taffy"
    end

    if player.components.eater ~= nil and player.components.eater.preferseatingtags ~= nil and TableContains(player.components.eater.preferseatingtags, "preparedfood") then
        foodPrefab = "taffy"
    end

    if player.prefab == "wortox" then
        foodPrefab = "blue_cap_cooked"
    end

    for i = 1, 7 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect(foodPrefab, x, y, z)
        end)
    end

    for i = 1, 2 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("pumpkin_lantern", x, y, z)
        end)
    end
end

local function SpawnFirePit(inst, player, ailment)
    local firepit
    local x, y, z = player.Transform:GetWorldPosition()
    
    if ailment == "overheating" then
        firepit = SpawnWithEffect("coldfirepit", x, y, z, true, nil, player)
    else
        firepit = SpawnWithEffect("firepit", x, y, z, true, "firepit_fanged", player)
    end

    firepit.components.fueled:SetPercent(1)

    inst:DoTaskInTime(DISCORD_EVENT_POSITIVE_FIREPIT_TIME + math.random(DISCORD_EVENT_POSITIVE_FIREPIT_TIME), function()
        if player ~= nil and firepit ~= nil and firepit:IsValid() and firepit.components.workable.onfinish ~= nil then
            firepit.components.workable.onfinish(firepit, player)
        end
    end)

    if ailment == "freezing" or ailment == "overheating" then
        player:DoTaskInTime(0.2 + math.random(4) * 0.3, function()
            if player ~= nil then
                SpawnWithEffect("heatrock", x, y, z, nil, "heatrock_fire", player)
            end
        end)
    end
end

local function SpawnBoosterShot(player)
    local x, y, z = player.Transform:GetWorldPosition()
    SpawnWithEffect("lifeinjector", x, y, z)
end

local function SpawnBasicSupplies(player)
    local x, y, z = player.Transform:GetWorldPosition()

    for i = 1, 5 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("cutgrass", x, y, z)
        end)
    end

    for i = 1, 6 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("twigs", x, y, z)
        end)
    end

    for i = 1, 3 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("flint", x, y, z)
        end)
    end
end

local function SpawnHounds(player)
    local x, y, z = player.Transform:GetWorldPosition()
    
    for i = 1, 5 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            SpawnWithEffect("mutatedhound", x, y, z)
        end)
    end
end

local function TeleportSomewhere(player)
    local x, y, z = player.Transform:GetWorldPosition()
    ents = GLOBAL.TheSim:FindEntities(x, y, z, 9001)
    if #ents > 0 then
        local randomEnt = ents[math.random(1, #ents)]
        local new_x, new_y, new_z = randomEnt.Transform:GetWorldPosition()
        TeleportWithEffect(player, new_x, new_y, new_z)
    end
end

local function DropEverything(player)
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

local function MeteorShower(player)
    local meteorPrefab = "shadowmeteor"
    local x, y, z = player.Transform:GetWorldPosition()
    
    for i = 1, 10 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            GLOBAL.TheSim:LoadPrefabs({ meteorPrefab })
            local meteor = SpawnPrefab(meteorPrefab)
			meteor.Transform:SetPosition(x + math.random(-8,8), y, z + math.random(-8,8))
        end)
    end

    for i = 1, 15 do
        player:DoTaskInTime(0.2 * i + math.random(4) * 0.3, function()
            GLOBAL.TheWorld:PushEvent("ms_sendlightningstrike", Vector3(x + math.random(-8,8), y, z + math.random(-8,8)))
        end)
    end
end


local function DoDiscordAssistEvent(sender_shard_id)
    if GLOBAL.TheWorld ~= nil then

        -- For all players online
        for i, player in ipairs(AllPlayers) do

            -- Check if something happens at all
            if math.random() < DISCORD_EVENT_OCCURANCE_CHANCE then

                -- Check if something positive happens
                if math.random() < DISCORD_EVENT_POSITIVE_CHANCE then

                    if player:HasTag("playerghost") then
                        DoResurrection(player, "The People")

                    elseif player.LightWatcher ~= nil and not player.LightWatcher:IsInLight() then
                        SpawnFirePit(GLOBAL.TheWorld, player)

                    elseif player.GetTemperature(player) < DISCORD_EVENT_POSITIVE_FREEZING_THRESHOLD then
                        SpawnFirePit(GLOBAL.TheWorld, player, "freezing")

                    elseif player.GetTemperature(player) > DISCORD_EVENT_POSITIVE_OVERHEATING_THRESHOLD then
                        SpawnFirePit(GLOBAL.TheWorld, player, "overheating")

                    elseif IsBlackDeathModEnabled() and player.components.tiddlevirus ~= nil and player.components.tiddlevirus.active == true then
                        CureVirus(player)

                    elseif player.components.health ~= nil and player.components.health.penalty ~= nil and player.components.health.penalty > 0 then
                        SpawnBoosterShot(player)

                    elseif player.components.health ~= nil and player.components.health:GetPercent() < DISCORD_EVENT_POSITIVE_HEALTH_THRESHOLD then
                        SpawnHealingSalves(player)

                    elseif player.components.hunger ~= nil and player.components.hunger:GetPercent() < DISCORD_EVENT_POSITIVE_HUNGER_THRESHOLD then
                        SpawnFood(player)

                    elseif player.components.sanity ~= nil and player.components.sanity:GetPercent() < DISCORD_EVENT_POSITIVE_SANITY_THRESHOLD then
                        SpawnSanityHelp(player)

                    else
                        SpawnBasicSupplies(player)

                    end

                -- Something negative happens instead
                else

                    local event_chosen = math.random(4)

                    if event_chosen == 1 then
                        SpawnHounds(player)

                    elseif event_chosen == 2 then
                        TeleportSomewhere(player)

                    elseif event_chosen == 3 then
                        DropEverything(player)

                    elseif event_chosen == 4 then
                        MeteorShower(player)

                    end

                end

            end

        end

    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_discord_assist_event", DoDiscordAssistEvent)

function c_discord_trigger_assist()
    SuUsed("c_discord_trigger_assist", true)

    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_discord_assist_event"), nil)
end

-- Register as global command accessible from console
GLOBAL.c_discord_trigger_assist = c_discord_trigger_assist


-- Recieve chat message from Discord
local function clientDiscordDisplayMessage(name, message)
    Networking_Say(nil, nil, "[D] " .. name, nil, message, PLAYERCOLOURS.VIOLETRED)
end

AddClientModRPCHandler(MADNESS_RPC_NAME, "client_discord_send_message", clientDiscordDisplayMessage)

local function DiscordSendMessage(sender_shard_id, name, message)
    -- Send to all connected clients of this shard
    SendModRPCToClient(GetClientModRPC(MADNESS_RPC_NAME, "client_discord_send_message"), nil, name, message)
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_discord_send_message", DiscordSendMessage)

function c_discord_send_message(name, message)
    -- Send to all connected shards
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_discord_send_message"), nil, name, message)
end

-- Register as global command accessible from console
GLOBAL.c_discord_send_message = c_discord_send_message
