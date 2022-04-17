-- Imports
local STRINGS = GLOBAL.STRINGS
local SEASONS = GLOBAL.SEASONS
local AllPlayers = GLOBAL.AllPlayers
local SpawnPrefab = GLOBAL.SpawnPrefab
local OnSimPaused = GLOBAL.OnSimPaused
local Networking_Say = GLOBAL.Networking_Say
local Networking_Announcement = GLOBAL.Networking_Announcement
local Networking_JoinAnnouncement = GLOBAL.Networking_JoinAnnouncement
local Networking_LeaveAnnouncement = GLOBAL.Networking_LeaveAnnouncement
local GetNewRezAnnouncementString = GLOBAL.GetNewRezAnnouncementString
local GetNewDeathAnnouncementString = GLOBAL.GetNewDeathAnnouncementString
local Networking_ModOutOfDateAnnouncement = GLOBAL.Networking_ModOutOfDateAnnouncement
modimport("features/discord_logging/constants.lua")
modimport("features/discord_logging/extra_logging.lua")

-- Network Join/Leave Announcements
local function BuildLoginLogoutMessage(mode, name)
    if name ~= nil then

        local login_text = " has signed in."
        local logout_text = " has signed out."

        if mode == "connected" then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["login"] .. name .. login_text)
        elseif mode == "disconnected" then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["logout"] .. name .. logout_text)
        end

    end
end

local function HookIntoNetworkJoinLeaveAnnouncements()

    local _Networking_JoinAnnouncement = Networking_JoinAnnouncement
    GLOBAL.Networking_JoinAnnouncement = function(name, colour)
        BuildLoginLogoutMessage("connected", name)
        _Networking_JoinAnnouncement(name, colour)
    end

    local _Networking_LeaveAnnouncement = Networking_LeaveAnnouncement
    GLOBAL.Networking_LeaveAnnouncement = function(name, colour)
        BuildLoginLogoutMessage("disconnected", name)
        _Networking_LeaveAnnouncement(name, colour)
    end

    local _Networking_ModOutOfDateAnnouncement = Networking_ModOutOfDateAnnouncement
    GLOBAL.Networking_ModOutOfDateAnnouncement = function(mod)
        SendMessageToDiscord(DISCORD_WARNING_EMOJI .. "`Mod " .. mod .. " is out of date and the server needs to be updated.`", "mod-check")
        _Networking_ModOutOfDateAnnouncement(mod)
    end

    local _Networking_Say = Networking_Say
    GLOBAL.Networking_Say = function(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
        SendMessageToDiscord(PrefabToEmoji(prefab) .. "`" .. name .. ": " .. message .. "`")
        _Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity)
    end

end

-- Log At Sim Paused (to catch events when the server has started up)
local function HookIntoSimPaused()
    local _OnSimPaused = OnSimPaused
    GLOBAL.OnSimPaused = function()
        parseAll("simpaused")
        _OnSimPaused()
    end
end

-- On Resurrect
local function OnResurrect(inst, data)
    parseAll("resurrect", inst)
    SendMessageToDiscord(DISCORD_EMOJIS.STATUS["resurrect"] .. GetNewRezAnnouncementString(inst, inst.rezsource))
end

-- On Death
local function OnDeath(inst, data)
    parseAll("death", inst)
    SendMessageToDiscord(DISCORD_EMOJIS.STATUS["death"] .. GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet))
end

-- On Season Change
local function OnSeasonChange(inst, data)
    local season = data.season

    if season ~= nil then
        if season == SEASONS.AUTUMN then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["autumn"] .. "Autumn has begun !")
        elseif season == SEASONS.WINTER then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["winter"] .. "Winter has begun !")
        elseif season == SEASONS.SPRING then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["spring"] .. "Spring has begun !")
        elseif season == SEASONS.SUMMER then
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["summer"] .. "Summer has begun !")
        end
    end

    parseAll("newseason")
end

-- On World Reset
local function OnWorldReset(inst)
    SendMessageToDiscord(DISCORD_EMOJIS.STATUS["reset"] .. "The world has been wiped anew.")
end

-- On Connect
local function OnConnection(inst, data)
    parseAll("connected")
end

local function OnLogin(inst, player)
    parseAll("joined")
end

local function clientDisplayLoginAnnouncement(message)
    Networking_Announcement(message, nil, "none")
end

AddClientModRPCHandler(MADNESS_RPC_NAME, "client_login_message", clientDisplayLoginAnnouncement)

local function sendClientAnnouncement(player, message)
    if player ~= nil then
        SendModRPCToClient(GetClientModRPC(MADNESS_RPC_NAME, "client_login_message"), player.userid, message)
    end
end

local function OnNewPlayerSpawn(inst, player)
    local username = player:GetDisplayName()
    if username ~= nil and player.prefab ~= nil then
        SendMessageToDiscord(PrefabToEmoji(player.prefab) .. username .. " has selected " .. STRINGS.NAMES[string.upper(player.prefab)] .. ".")
    end

    -- Send message on login
    player:DoTaskInTime(5, function() sendClientAnnouncement(player, "Welcome...") end)
    player:DoTaskInTime(10, function() sendClientAnnouncement(player, "to madness.") end)
    player:DoTaskInTime(20, function() sendClientAnnouncement(player, "This is a hard server - survive through the year") end)
    player:DoTaskInTime(27, function() sendClientAnnouncement(player, "...if you can.") end)
end

-- Madness World Reset Update
local function OnMadnessResetGlommer(inst)
    SendMessageToDiscord(DISCORD_EMOJIS.STATUS["flower"] .. "Glommer was found and certain doom is delayed... for now.")
end

local function OnMadnessResetAtrium(inst, data)
    local announcement = data.announcement
    if announcement ~= nil then
        SendMessageToDiscord(DISCORD_EMOJIS.STATUS["torch"] .. announcement)
    end
end

local function OnMadnessResetAnnouncement(inst, data)
    local announcement = data.announcement
    if announcement ~= nil then
        SendMessageToDiscord(DISCORD_EMOJIS.STATUS["death"] .. announcement)
    end
end

local function OnMadnessResetUpdate(inst, data)
    parseAll("madness_world_reset_update")
end

-- On Disconnect
local function OnDisconnection(inst, data)
    parseAll("disconnected")
end

local function OnLogout(inst, player)
    parseAll("left")
end

local function DoAchievementEffect(player)
    if player ~= nil then

        local fx
        local x, y, z = player.Transform:GetWorldPosition()

        if player:HasTag("playerghost") then
            DoResurrection(player, "Tenacious Survival")
        end

        if player.components.health ~= nil and player.components.hunger ~= nil and player.components.sanity ~= nil then
            player.components.health:SetPenalty(0)
            player.components.health:SetPercent(1)
            player.components.hunger:SetPercent(1)
            player.components.sanity:SetPercent(1)
        end

        fx = SpawnPrefab("halloween_firepuff_3")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end
        fx = SpawnPrefab("crab_king_shine")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end
        fx = SpawnPrefab("wathgrithr_spirit")
        if fx ~= nil then
            fx.Transform:SetPosition(x, y, z)
        end

    end
end

-- On Cycle Change
local function OnCycleChange()
    parseAll("newday")

    -- Check for new year passing
    if GLOBAL.TheWorld.state.cycles ~= 0 and (GLOBAL.TheWorld.state.cycles % CountDaysInAYear()) == 0 then
        if IsMasterShard() then
            local win_message = "Congratulations ! " .. GLOBAL.TheNet:GetServerName() .. " has endured through a full year !"
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["achievement"] .. win_message)
            GLOBAL.TheNet:Announce("󰀭 " .. win_message, nil, nil, "none")
        end
        
        for i, player in ipairs(AllPlayers) do
            DoAchievementEffect(player)
            player.SoundEmitter:PlaySound("madness_sounds/survival_achievement/team")
        end
    end

    -- Check to see which players made it through a new year
    for i, player in ipairs(AllPlayers) do
        if player.components.age ~= nil and player.components.age:GetAgeInDays() ~= 0 and (player.components.age:GetAgeInDays() % CountDaysInAYear()) == 0 then
            local player_win_message = "Victory ! " .. player:GetBasicDisplayName() .. " has survived a full year in " .. GLOBAL.TheNet:GetServerName() .. " and has entered the hall of fame !"
            SendMessageToDiscord(DISCORD_EMOJIS.STATUS["achievement"] .. player_win_message)
            GLOBAL.TheNet:Announce("󰀭 " .. player_win_message, nil, nil, "none")
            DoAchievementEffect(player)
            player.SoundEmitter:PlaySound("madness_sounds/survival_achievement/individual")

            -- Hall of Fame
            AddToHallOfFame(player)
        end
    end
end

-- On Phase Change
local function OnPhaseChange(inst, phase)
    log({
        category="newphase",
        phase=phase,
    })
end

-- Catch events in all players
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil then
      
      -- Resurrect Announcement
      inst:ListenForEvent("respawnfromghost", OnResurrect)

      -- Death Announcement
      inst:ListenForEvent("death", OnDeath)
  
    end
end)

-- World events
AddSimPostInit(function()

    -- Clients have no business sending stuff to Discord...
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    -- The following must only trigger on the master shard
    if IsMasterShard() then

        -- Capture Join/Leave events to exclude shard migrations
        HookIntoNetworkJoinLeaveAnnouncements()

        -- Simulation Paused Check
        HookIntoSimPaused()

        -- Season Change
        GLOBAL.TheWorld:ListenForEvent("madness_seasonchanged", OnSeasonChange)

        -- World Reset
        GLOBAL.TheWorld:ListenForEvent("ms_worldreset", OnWorldReset)

        -- Madness World Reset Events
        if GetModConfigData("MadnessWorldResets") == true then
            GLOBAL.TheWorld:ListenForEvent("madness_world_reset_announcement", OnMadnessResetAnnouncement)
            GLOBAL.TheWorld:ListenForEvent("madness_world_reset_update", OnMadnessResetUpdate)
        end

    end

    -- Madness World Reset Events
    if GetModConfigData("MadnessWorldResets") == true then
        GLOBAL.TheWorld:ListenForEvent("madness_world_reset_glommer", OnMadnessResetGlommer)
        GLOBAL.TheWorld:ListenForEvent("madness_world_reset_atrium", OnMadnessResetAtrium)
    end

    -- Login/Logout Logging
    GLOBAL.TheWorld:ListenForEvent("ms_playerjoined", OnLogin)
    GLOBAL.TheWorld:ListenForEvent("ms_clientauthenticationcomplete", OnConnection)
    GLOBAL.TheWorld:ListenForEvent("ms_newplayerspawned", OnNewPlayerSpawn)

    GLOBAL.TheWorld:ListenForEvent("ms_playerleft", OnLogout)
    GLOBAL.TheWorld:ListenForEvent("ms_clientdisconnected", OnDisconnection)

    -- Extra logging
    GLOBAL.TheWorld:ListenForEvent("phasechanged", OnPhaseChange)
    GLOBAL.TheWorld:ListenForEvent("cycleschanged", OnCycleChange)

end)
