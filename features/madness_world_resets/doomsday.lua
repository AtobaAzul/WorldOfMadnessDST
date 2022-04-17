-- Imports
local TUNING = GLOBAL.TUNING
local AllPlayers = GLOBAL.AllPlayers
local CAMERASHAKE = GLOBAL.CAMERASHAKE
local ShakeAllCameras = GLOBAL.ShakeAllCameras
modimport("features/madness_world_resets/constants.lua")

-- Protected Flag
local worldProtected = false

-- Earthquakes
local earthquakesEnabled = false
local earthquakeChance = 0

local function DoEarthquakeTask()
    if earthquakesEnabled and not IsWorldResetDisabled() and math.random() < earthquakeChance then
        StartEarthquake(WORLD_RESET_EARTHQUAKE_DURATION)
    end
end

function StopEarthquakes()
    earthquakesEnabled = false
    earthquakeChance = 0
end

local function SetEarthquakeChance(chance)
    earthquakesEnabled = true
    earthquakeChance = chance
end

local function OnLogin(inst, player)
    if IsWorldResetForced() then
        if player ~= nil and player.SoundEmitter ~= nil then
            if GLOBAL.TheWorld.worldprefab == "forest" then
                player.SoundEmitter:PlaySound("madness_sounds/madness_world_reset/final_hours", "final_hours")
            else
                player.SoundEmitter:PlaySound("madness_sounds/madness_world_reset/final_hours_caves", "final_hours")
            end
        end
    end
end

-- New Day Announcement
local function announceNewDay(dayStr, remainStr, quakechance)
    local announceString = "Dawn of the " .. dayStr .. " day... " .. remainStr .. "..."
    GLOBAL.TheNet:Announce("󰀕 " .. announceString, nil, nil, "none")
    PlayNetworkedSound("new_day", "madness_sounds/madness_world_reset/newday")
    GLOBAL.TheWorld:DoTaskInTime(3, function()
        GLOBAL.TheNet:Announce("Insert a Cratered Moonrock into the Ancient Gateway or the Celestial Altar to avoid certain death.", nil, nil, "none")
    end)
    SetEarthquakeChance(quakechance)
    GLOBAL.TheWorld:PushEvent("madness_world_reset_announcement", {announcement = announceString})
end

-- On Cycle Change
local function OnCycleChange()
    -- Full Moons happen every 20 days after the 11th day
    local day = GLOBAL.TheWorld.state.cycles + 1

    if IsWorldResetDisabled() then
        worldProtected = true
    end

    -- Skip the first moon cycle
    if day > (WORLD_RESET_START_AFTER_DATE + TUNING.MADNESS.world_reset_glommer_extra_days) then

        -- Dawn of the 1st day
        if (not worldProtected) and (((day - 9) % 20) == 0) then
            announceNewDay("first", "3 days remain", WORLD_RESET_EARTHQUAKE_BASE_CHANCE)

        -- Dawn of the 2nd day
        elseif (not worldProtected) and (((day - 10) % 20) == 0) then
            announceNewDay("second", "2 days remain", WORLD_RESET_EARTHQUAKE_BASE_CHANCE + 0.1)

        -- Dawn of the final day
        elseif (not worldProtected) and (((day - 11) % 20) == 0) then
            announceNewDay("final", "1 day remains", WORLD_RESET_EARTHQUAKE_BASE_CHANCE + 0.3)
            StartEarthquake(WORLD_RESET_EARTHQUAKE_DURATION)
            GLOBAL.TheWorld:DoTaskInTime(240, function()
                if not IsWorldResetDisabled() then
                    ForceWorldReset()
                    StartEarthquake(WORLD_RESET_EARTHQUAKE_DURATION)
                    GLOBAL.TheWorld:PushEvent("madness_world_reset_announcement", {announcement = "The world is about to be destroyed..."})
                end
            end)

        -- Force server reset if it doesn't happen somehow...
        elseif IsWorldResetForced() and (((day - 12) % 20) == 0) then
            GLOBAL.TheNet:SendWorldResetRequestToServer()

        end

        -- Reset world protection
        if (((day - 9) % 20) ~= 0) and (((day - 10) % 20) ~= 0) and (((day - 11) % 20) ~= 0) then
            worldProtected = false
        end

    end
end

-- World events
-- Does not need to be networked since cycles
-- are managed by the master shard
AddSimPostInit(function()
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    if IsMasterShard() then
        GLOBAL.TheWorld:ListenForEvent("cycleschanged", OnCycleChange)
        GLOBAL.TheWorld:DoPeriodicTask(WORLD_RESET_EARTHQUAKE_MINIMUM_COOLDOWN, DoEarthquakeTask)
    end

    -- For music handling
    GLOBAL.TheWorld:ListenForEvent("ms_playerjoined", OnLogin)
end)
