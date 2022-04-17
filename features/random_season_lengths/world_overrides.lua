-- Imports
local TUNING = GLOBAL.TUNING
local SEASONS = GLOBAL.SEASONS
modimport("features/random_season_lengths/constants.lua")

local daysToAssign = 0

local function assignDays(seasons_left)
    local days = 0
    local upperBound = daysToAssign - (MINIMUM_SEASON_LENGTH * seasons_left)
    if MAXIMUM_SEASON_LENGTH ~= nil then upperBound = MAXIMUM_SEASON_LENGTH end

    if MINIMUM_SEASON_LENGTH > upperBound then
        days = MINIMUM_SEASON_LENGTH
    else
        days = math.random(MINIMUM_SEASON_LENGTH, upperBound)
    end

    daysToAssign = daysToAssign - days
    return days
end

local function swapDays(first, second)
    return second, first
end

local function randomizeSeasonLengths()
    daysToAssign = CountDaysInAYear()

    -- Generate max days if nil
    if MAXIMUM_SEASON_LENGTH == nil then
        MAXIMUM_SEASON_LENGTH = math.floor(daysToAssign / 4)
    end

    local autumn_days = assignDays(3)
    local winter_days = assignDays(2)
    local spring_days = assignDays(1)
    local summer_days = assignDays(0)

    -- Distribute whatever's left evenly
    if daysToAssign > 0 then
        local split_days = math.floor(daysToAssign / 4)
        daysToAssign = daysToAssign - (split_days * 4)
        autumn_days = autumn_days + split_days
        winter_days = winter_days + split_days + daysToAssign -- Because long winters are fun
        spring_days = spring_days + split_days
        summer_days = summer_days + split_days
    elseif daysToAssign < 0 then
        daysToAssign = daysToAssign * -1
        local split_days = math.floor(daysToAssign / 4)
        daysToAssign = daysToAssign - (split_days * 4)
        autumn_days = autumn_days - split_days - daysToAssign -- Because nobody likes long autumns
        winter_days = winter_days - split_days
        spring_days = spring_days - split_days
        summer_days = summer_days - split_days
    end

    if GetModConfigData("LongerHarshSeasons") == true then
        if winter_days < autumn_days then
            winter_days, autumn_days = swapDays(winter_days, autumn_days)
        end

        if winter_days < spring_days then
            winter_days, spring_days = swapDays(winter_days, spring_days)
        end

        if summer_days < autumn_days then
            summer_days, autumn_days = swapDays(summer_days, autumn_days)
        end

        if summer_days < spring_days then
            summer_days, spring_days = swapDays(summer_days, spring_days)
        end
    end

    if (autumn_days + winter_days + spring_days + summer_days) == CountDaysInAYear() then
        GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season=SEASONS.AUTUMN, length=autumn_days})
        GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season=SEASONS.WINTER, length=winter_days})
        GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season=SEASONS.SPRING, length=spring_days})
        GLOBAL.TheWorld:PushEvent("ms_setseasonlength", {season=SEASONS.SUMMER, length=summer_days})

        -- In case these get referenced (they do in sinkholespawner code...)
        TUNING.AUTUMN_LENGTH = autumn_days
        TUNING.WINTER_LENGTH = winter_days
        TUNING.SPRING_LENGTH = spring_days
        TUNING.SUMMER_LENGTH = summer_days

        -- There is some sort of bug on new years - set the season every time to refresh the day count
        GLOBAL.TheWorld:PushEvent("ms_setseason", GLOBAL.TheWorld.state.season)
    end
end

local function setStartingSeason()
    if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.state ~= nil then
        GLOBAL.TheWorld.state.madness_starting_season = SEASON_LIST[math.random(1, #SEASON_LIST)]
        GLOBAL.TheWorld:PushEvent("ms_setseason", GLOBAL.TheWorld.state.madness_starting_season)
    end
end

function getStartingSeason()
    if GLOBAL.TheWorld ~= nil and GLOBAL.TheWorld.state ~= nil and GLOBAL.TheWorld.state.madness_starting_season ~= "none" then
        return GLOBAL.TheWorld.state.madness_starting_season
    end

    return nil
end

local function OnSeasonChange(inst, data)
    local season = data.season

    if season ~= nil and season == getStartingSeason() then
        randomizeSeasonLengths()
    end
end

AddComponentPostInit("worldstate", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Add a new variable to save
    self.data.madness_starting_season = "none"
end)

-- World events
AddSimPostInit(function()

    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- The following must only trigger on the master shard
    if IsMasterShard() then
        -- Initially set the starting season
        if getStartingSeason() == nil then
            setStartingSeason()
        end

        -- Capture Season change to re-randomize after a year has passed
        GLOBAL.TheWorld:ListenForEvent("madness_seasonchanged", OnSeasonChange)
    end

end)
