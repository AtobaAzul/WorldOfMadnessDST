-- Imports
local TUNING = GLOBAL.TUNING
modimport("features/penalty_on_logout/constants.lua")

local function applyLogoutPenalty(inst, player)
    if player ~= nil and player.components.debuffable ~= nil and not player:HasTag("playerghost") then

        -- Check if it is close to nightfall or if it is night time, in combat, or in the dark
        if (IsInCombat(player))
        or (GLOBAL.TheWorld.net ~= nil and GLOBAL.TheWorld.net.components.clock ~= nil and GLOBAL.TheWorld.net.components.clock:GetTimeUntilPhase("night") < (HEALTH_PENALTY_SEGMENTS_UNTIL_NIGHT * TUNING.SEG_TIME))
        or (player.LightWatcher ~= nil and not player.LightWatcher:IsInLight()) then
            player.components.debuffable:AddDebuff("buff_madnesslogoutpenalty", "buff_madnesslogoutpenalty")
        end

    end
end

-- Hook into the Player Spawner component
AddComponentPostInit("playerspawner", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Capture relevant despawn event
    self.inst:ListenForEvent("ms_playerdespawn", applyLogoutPenalty)
end)
