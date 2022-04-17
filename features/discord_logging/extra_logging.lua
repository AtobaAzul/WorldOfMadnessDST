-- Imports
local json = GLOBAL.json
local pcall = GLOBAL.pcall
local SuUsed = GLOBAL.SuUsed
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local checkbit = GLOBAL.checkbit
local USERFLAGS = GLOBAL.USERFLAGS
local UserToPlayer = GLOBAL.UserToPlayer

-- Discord Emojis
DISCORD_EMOJIS = TableLoadFromString(GetModConfigData("DiscordLoggingEmojis"))

-- Discord Webhook API Table
local DISCORD_URLS = TableLoadFromString(GetModConfigData("DiscordLogging"))

-- Convert prefab to discord emoji
function PrefabToEmoji(prefab)
    if prefab ~= nil and STRINGS.NAMES[string.upper(prefab)] ~= nil and DISCORD_EMOJIS.CHARACTERS[prefab] ~= nil then
        return "<:" .. string.lower(string.gsub(STRINGS.NAMES[string.upper(prefab)], "-", "")) .. ":" .. DISCORD_EMOJIS.CHARACTERS[prefab] .. "> "
    end
    return DISCORD_UNKNOWN_EMOJI
end

-- Main logging function
function log(result)
    if result.near and result.near.structures then 
        local structures = {}
        for k,v in ipairs(result.near.structures) do
            if v ~= result.object then 
                table.insert(structures, parseObject(v))    
            end
        end
        result.near.structures = structures
    end
    
    -- needs to be food before player
    if result.food and result.player then 
        local food, player = parseFood(result.food, result.player)
        result.food, result.player = food, player
    elseif result.player then 
        local player = parsePlayer(result.player)
        result.player = player
    end

    if result.object then
        local object = parseObject(result.object)
        result.object = object
    end

    if result.feeder then 
        local feeder = parsePlayer(result.feeder)
        result.feeder = feeder
    end

    print('[DFTA] ' .. json.encode(result))
end

-- Main Parsing function
function parseAll(category, inst)
    local data = nil
    if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.state ~= nil then 
        data = GLOBAL.TheWorld.state
    end

    local players = {}
    for i, v in ipairs(GLOBAL.TheNet:GetClientTable()) do
        local player = UserToPlayer(v.userid)
        local is_ghost = checkbit(v.userflags, USERFLAGS.IS_GHOST)
        local in_caves = ( v.playerage > 0 and ((IsMasterShard() and player == nil) or (not IsMasterShard() and player ~= nil)) )

        if player ~= nil then
            -- Override if we got a death or resurrect event, as the parse call occurs before the tag gets updated
            if inst ~= nil and player == inst then
                if category == "resurrect" then
                    is_ghost = false
                elseif category == "death" then
                    is_ghost = true
                end
            end
        end

        if GLOBAL.TheNet:GetServerIsClientHosted() or v.performance == nil then
            table.insert(players, {
                prefab = v.prefab,
                age = v.playerage,
                flags = v.userflags,
                cave = in_caves,
                ghost = is_ghost,
                userid = v.userid,
                name = v.name
            })
        end
    end
    
    log({
        category=category,
        day=data.cycles+1,
        remainingdaysinseason=data.remainingdaysinseason,
        season=data.season,
        phase=data.phase,
        moonphase=data.moonphase,
        maxplayers=GLOBAL.TheNet:GetServerMaxPlayers(),
        players=players,
        madnessresetstate=TUNING.MADNESS.world_reset_ghost_count or -1,
        isCave=not IsMasterShard()
    })
end

-- Main Discord message sending
function SendMessageToDiscord(message, channel)
    local url = DISCORD_URLS.DISCORD_WEBHOOKS.game_chat
    if channel ~= nil then
        if channel == "hall-of-fame" then
            url = DISCORD_URLS.DISCORD_WEBHOOKS.hall_of_fame
        elseif channel == "mod-check" then
            url = DISCORD_URLS.DISCORD_WEBHOOKS.mod_check
        elseif channel == "general" then
            url = DISCORD_URLS.DISCORD_WEBHOOKS.general
        end
    end
    message = string.gsub(string.gsub(message, "[^%w%p%s`]", ""), "'", "’")
    GLOBAL.TheSim:QueryServer(
		url,
        function(...)
            if channel ~= nil then
                print("Sending '" .. message .. "' to the " .. channel .. " channel on Discord.")
            else
                print("Sending '" .. message .. "' to the game-chat channel on Discord.")
            end
		end,
		"POST",
		json.encode({
			content = message
		})
    )
end

-- Send Hall of Fame to Discord
function SendHallOfFameToDiscord()
    -- Get Hall of Fame information
    GLOBAL.TheSim:QueryServer(
        DISCORD_URLS.HALL_OF_FAME.url .. "?authkey=" .. DISCORD_URLS.HALL_OF_FAME.authkey,
        function(hall_of_fame, isSuccessful, resultCode)
            if isSuccessful and string.len(hall_of_fame) > 0 and resultCode == 200 then
                local status, hall_of_fame = pcall( function() return json.decode(hall_of_fame) end )
                if hall_of_fame ~= nil then

                    local discord_string = "Hall of fame:\n" .. DISCORD_EMOJIS.STATUS["achievement"] .. "Survivors that have lived for over an in-game year are listed here, along with the character they have survived with :\n\n"
                    for k, item in pairs(hall_of_fame.data) do
                        if item.badge == 1 then discord_string = discord_string .. DISCORD_EMOJIS.STATUS["gold"]
                        elseif item.badge == 2 then discord_string = discord_string .. DISCORD_EMOJIS.STATUS["silver"]
                        elseif item.badge == 3 then discord_string = discord_string .. DISCORD_EMOJIS.STATUS["bronze"]
                        else discord_string = discord_string .. DISCORD_EMOJIS.STATUS["nobadge"] end

                        discord_string = discord_string .. "`" .. item.namestr .. "` "
                        
                        for j, prefab in pairs(item.prefabs) do
                            discord_string = discord_string .. PrefabToEmoji(prefab)
                        end
                        discord_string = string.sub(discord_string, 1, string.len(discord_string) - 1) .. "\n"
                    end
                    discord_string = discord_string .. "\nBeing listed 7 times makes the survivor a true <@&" .. DISCORD_URLS.HALL_OF_FAME.roleid .. ">."
                    SendMessageToDiscord(discord_string, "hall-of-fame")

                end
            end
        end,
        "GET"
    )
end

local function c_discord_send_hof()
    SuUsed("c_discord_send_hof", true)

    SendHallOfFameToDiscord()
end

-- Register as global command accessible from console
GLOBAL.c_discord_send_hof = c_discord_send_hof

-- Send To Hall of Fame
function AddToHallOfFame(player)
    -- Fetch Session ID
    GetWorldSessionID()

    GLOBAL.TheWorld:DoTaskInTime(5, function(world)
        if player ~= nil and player.components.age ~= nil then

            -- Add Player
            GLOBAL.TheSim:QueryServer(
                DISCORD_URLS.HALL_OF_FAME.url .. "?authkey=" .. DISCORD_URLS.HALL_OF_FAME.authkey,
                function(...)
                    print("Sending '" .. player:GetBasicDisplayName() .. "' to the Hall of Fame server.")
                end,
                "POST",
                json.encode({
                    username = player:GetBasicDisplayName(),
                    prefab = player.prefab,
                    session_id = TUNING.MADNESS.SESSION_ID,
                    years_survived = math.floor(player.components.age:GetAgeInDays() / CountDaysInAYear())
                })
            )
            SendHallOfFameToDiscord()

        end
    end)
end

local function parsePlayer(player)
    return {
        name = player:GetBasicDisplayName(),
        guid = player.guid,
        userid = player.userid,
        prefab = player.prefab,
    }
end

local function parseObject(object)
    local owner = {} 
    if object.dfta_owner then 
        owner = parsePlayer(object.dfta_owner)
    end
    return {
        name = object:GetBasicDisplayName(),
        guid = object.guid,
        userid = object.userid,
        prefab = object.prefab,
        owner = owner,
        burnt = object:HasTag("burnt"),
    }
end 

local function parseFood(food, player)
    return {
        name = food:GetBasicDisplayName(),
        prefab = food.prefab,
        val_health = food.components.edible.healthvalue * player.components.eater.healthabsorption,
        val_sanity = food.components.edible.sanityvalue * player.components.eater.hungerabsorption,
        val_hunger = food.components.edible.hungervalue * player.components.eater.sanityabsorption,        
    },
    
    {
        name = player:GetBasicDisplayName(),
        guid = player.guid,
        userid = player.userid,
        prefab = player.prefab,
        stats = {
            maxhealth = player.components.health.maxhealth,
            maxsanity = player.components.sanity.max,
            maxhunger = player.components.hunger.max,
            maxhealth_penalty = player.components.health.penalty,
            maxsanity_penalty = player.components.sanity.penalty,
            health = player.components.health.currenthealth,
            sanity = player.components.sanity.current,
            hunger = player.components.hunger.current,
            invincible = player.components.health.invincible,
        }
    }
end
