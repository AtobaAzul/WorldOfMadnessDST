-- Imports
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local SEASONS = GLOBAL.SEASONS
local AllPlayers = GLOBAL.AllPlayers
local AllRecipes = GLOBAL.AllRecipes
local ArrayUnion = GLOBAL.ArrayUnion
local SpawnPrefab = GLOBAL.SpawnPrefab
local CAMERASHAKE = GLOBAL.CAMERASHAKE
local ShakeAllCameras = GLOBAL.ShakeAllCameras
local ANNOUNCEMENT_ICONS = GLOBAL.ANNOUNCEMENT_ICONS

-- Seasons List
SEASON_LIST =
{
    SEASONS.AUTUMN,
    SEASONS.WINTER,
    SEASONS.SPRING,
    SEASONS.SUMMER
}

function SpawnWithEffect(prefab, x, y, z, build, skin, player)
    local item
    x = x + math.random(-8,8)
    z = z + math.random(-8,8)

    --Portal FX
    if build == nil or not build then
        local fx = SpawnPrefab("spawn_fx_medium")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end
    end

    if skin ~= nil and player ~= nil then
        item = SpawnPrefab(prefab, skin, nil, player.userid)
    else
        item = SpawnPrefab(prefab)
    end
    item.Transform:SetPosition(x, y, z)

    if build ~= nil and build == true then
        if player ~= nil then
            item:PushEvent("onbuilt", { builder = player })
        else
            item:PushEvent("onbuilt")
        end
    end

    return item
end

function TeleportWithEffect(inst, x, y, z)
    local old_x, old_y, old_z = inst.Transform:GetWorldPosition()

    --Portal FX
    local fx = SpawnPrefab("spawn_fx_medium")
    if fx ~= nil then
        fx.Transform:SetPosition(old_x, old_y, old_z)
    end

    inst.Transform:SetPosition(x, y, z)
    
    --Portal FX
    local fx = SpawnPrefab("spawn_fx_medium")
    if fx ~= nil then
        fx.Transform:SetPosition(x, y, z)
    end
end

-- Is the player currently in combat state
function IsInCombat(player)
    if player ~= nil and player:HasTag("playerghost") then
        return false
    end

    if player.components.combat ~= nil and player.components.combat.target ~= nil and player.components.combat.target:IsValid() then
        return true
    end

    local x, y, z = player.Transform:GetWorldPosition()
    for i, v in ipairs(GLOBAL.TheSim:FindEntities(x, y, z, 40)) do
        if v ~= nil and v.components ~= nil and v.components.combat ~= nil and v.components.combat.target ~= nil and v.components.combat.target == player then
            return true
        end
    end

    return false
end

-- Get User's Network Name
function GetUserNetworkNameByID(userid)
    local username = nil

    local ClientObjs = GLOBAL.TheNet:GetClientTable()
    if userid ~= nil and ClientObjs ~= nil then
        for i, v in ipairs(ClientObjs) do
            if v.userid == userid then
                username = v.name
            end
        end
    end

    return username
end

-- Count Days in a Year
function CountDaysInAYear()
    return (GLOBAL.TheWorld.state.autumnlength + GLOBAL.TheWorld.state.winterlength + GLOBAL.TheWorld.state.springlength + GLOBAL.TheWorld.state.summerlength)
end

-- Create a transparent Announcement Widget Icon
ANNOUNCEMENT_ICONS.none = { atlas = "images/button_icons.xml", texture = "announcement.tex" }
AddClassPostConstruct("widgets/announcementwidget", function(self, font, size, colour)
    local originalSetIcon = self.SetIcon
    function self:SetIcon(announce_type)
        if announce_type == "none" then
            self.icon:Hide()
        else
            self.icon:Show()
        end
        originalSetIcon(self, announce_type)
    end
end)

function IsPlayerStarterItem(player_prefab, item_prefab)
    for k, item in pairs(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT[string.upper(player_prefab)]) do
        if item == item_prefab then
            return true
        end
    end

    return false
end

function IsStarterItem(prefab)
    for k, character in pairs(TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT) do
        if IsPlayerStarterItem(string.lower(k), prefab) then
            return true
        end
    end

    return false
end

function IsPlayer(inst)
    return (inst.isplayer ~= nil and inst.isplayer == true)
end

function GetRecipeSortKey(prefab)
    if AllRecipes[prefab] ~= nil then
        return AllRecipes[prefab].sortkey or 0
    end

    return 0
end

function GetIngredientPrefab(ingredient)
    if ingredient ~= nil then
        if IsGemCoreModEnabled() and ingredient.signature ~= nil then
            return string.sub(ingredient.signature, #"GEMDICT_" + 1)
        else
            return ingredient.type
        end
    end

    return nil
end

function GetRecipeIngredients(recipe)
    local ingredients = {}

    if recipe ~= nil then

        if IsGemCoreModEnabled() then
            ingredients = ArrayUnion(recipe.ingredients, recipe.gemdict_ingredients)
        else
            ingredients = recipe.ingredients
        end

    end

    return ingredients
end

function GetNameFromPrefab(prefab)
    return STRINGS.NAMES[string.upper(prefab)]
end

-- Summon Earthquake
local function StartShardEarthquake(sender_shard_id, length)
    local duration = length * math.random(0.5, 1.5)

    ShakeAllCameras(CAMERASHAKE.FULL, duration, .02, .5, nil, 40)
    for k, player in pairs(AllPlayers) do
        if player ~= nil and player.SoundEmitter ~= nil then
            player.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "madness_earthquake")
            player.SoundEmitter:SetParameter("madness_earthquake", "intensity", 2)
            player:DoTaskInTime(duration, function(inst)
                if player ~= nil and player.SoundEmitter ~= nil then
                    player.SoundEmitter:KillSound("madness_earthquake")
                end
            end)
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_earthquake", StartShardEarthquake)

function StartEarthquake(length)
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_earthquake"), nil, length)
end

-- Sound Handling
local function ShardPlayNetworkedSound(sender_shard_id, name, sound)
    for k, player in pairs(AllPlayers) do
        if player ~= nil and player.SoundEmitter ~= nil then
            player.SoundEmitter:PlaySound(sound, name)
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_start_sound", ShardPlayNetworkedSound)

function PlayNetworkedSound(name, sound)
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_start_sound"), nil, name, sound)
end

-- Stop Sound
local function ShardStopNetworkedSound(sender_shard_id, name)
    for k, player in pairs(AllPlayers) do
        if player ~= nil and player.SoundEmitter ~= nil then
            player.SoundEmitter:KillSound(name)
        end
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_stop_sound", ShardStopNetworkedSound)

function StopNetworkedSound(name)
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_stop_sound"), nil, name)
end

-- Get Main Game Session ID
local function ShardSetWorldSessionID(sender_shard_id, session_id)
    TUNING.MADNESS.SESSION_ID = session_id
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_world_set_sessionid", ShardSetWorldSessionID)

local function ShardGetWorldSessionID(sender_shard_id)
    -- Identify the current world by the Master Shard's session ID
    if IsMasterShard() then
        SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_world_set_sessionid"), nil, GLOBAL.TheNet:GetSessionIdentifier())
    end
end

AddShardModRPCHandler(MADNESS_RPC_NAME, "shard_world_get_sessionid", ShardGetWorldSessionID)

function GetWorldSessionID()
    SendModRPCToShard(GetShardModRPC(MADNESS_RPC_NAME, "shard_world_get_sessionid"), nil)
end

local function pushSeasonEnabled()
    -- World resets first set season to autumn and then to the randomly chosen season
    -- This handles only sending a season change event when the starting season is picked
    if GetModConfigData("RandomSeasonLengths") == true and GLOBAL.TheWorld.state.cycles == 0 and getStartingSeason() ~= GLOBAL.TheWorld.state.season then
        return false
    end

    return true
end

-- Need a more reliable season change event that is only called once every season change
local function OnSeasonChange()
    -- Needs to be delayed since ms_setseason takes time to synchronize
    GLOBAL.TheWorld:DoTaskInTime(0.1, function(world)
        if pushSeasonEnabled() and GLOBAL.TheWorld.state.season ~= GLOBAL.TheWorld.state.madness_previous_season then
            GLOBAL.TheWorld.state.madness_previous_season = GLOBAL.TheWorld.state.season
            GLOBAL.TheWorld:PushEvent("madness_seasonchanged", {season=GLOBAL.TheWorld.state.season})
        end
    end)
end

AddComponentPostInit("worldstate", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Add a new variable to save
    self.data.madness_previous_season = "none"
end)

-- World events
AddSimPostInit(function()
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Capture Season change
    GLOBAL.TheWorld:ListenForEvent("seasontick", OnSeasonChange)
end)
