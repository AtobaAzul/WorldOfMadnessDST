-- Imports
local SuUsed = GLOBAL.SuUsed
local COLLISION = GLOBAL.COLLISION
local ChangeToCharacterPhysics = GLOBAL.ChangeToCharacterPhysics

function c_becomecharlie()
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_becomecharlie", true)

        player.components.health:SetInvincible(true)
        player:Hide()
        player.DynamicShadow:Enable(false)
        player:AddTag("ignoretalking")
        player.Physics:ClearCollisionMask()
        player.Physics:CollidesWith(COLLISION.GROUND)
    end
end

function c_unbecomecharlie()
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_unbecomecharlie", true)
        
        player.components.health:SetInvincible(false)
        player:Show()
        player.DynamicShadow:Enable(true)
        player:RemoveTag("ignoretalking")
        ChangeToCharacterPhysics(player)
    end
end

-- Register as global command accessible from console
GLOBAL.c_becomecharlie = c_becomecharlie
GLOBAL.c_unbecomecharlie = c_unbecomecharlie

-- If Madness Reset Mode
if GetModConfigData("MadnessWorldResets") == true then
    function c_poweronatrium(silent, moon)
        SuUsed("c_poweronatrium", true)
        PowerOnAtrium(silent, moon)
    end

    -- Register as global command accessible from console
    GLOBAL.c_poweronatrium = c_poweronatrium

    function c_poweroffatrium(silent, moon)
        SuUsed("c_poweroffatrium", true)
        PowerOffAtrium(silent, moon)
    end

    -- Register as global command accessible from console
    GLOBAL.c_poweroffatrium = c_poweroffatrium

    function c_poweroffallatriums(silent)
        SuUsed("c_poweroffallatriums", true)
        PowerOffAllAtriums(silent)
    end

    -- Register as global command accessible from console
    GLOBAL.c_poweroffallatriums = c_poweroffallatriums
end

-- Check whether has virus or not
if IsBlackDeathModEnabled() then
    function c_hasvirus(inst)
        SuUsed("c_hasvirus", true)
        if not inst then
            inst = GLOBAL.ConsoleWorldEntityUnderMouse()
        end
        
        if inst ~= nil and inst.prefab ~= nil and inst.components.tiddlevirus ~= nil then
            if inst.components.tiddlevirus.active ~= nil and inst.components.tiddlevirus.active == true then
                print(inst.prefab .. " has the virus.")
                return true
            end
        end

        if inst ~= nil and inst.prefab ~= nil then
            print(inst.prefab .. " does not have the virus.")
        end
        return false
    end

    -- Register as global command accessible from console
    GLOBAL.c_hasvirus = c_hasvirus
end

-- Apply Logout Penalty Debuff
if GetModConfigData("PenaltyOnLogout") == true then
    function c_dologoutpenalty(inst)
        local player = GLOBAL.ConsoleCommandPlayer()
        if player ~= nil and player.components.debuffable ~= nil and not player:HasTag("playerghost") then
            SuUsed("c_dologoutpenalty", true)
            
            player.components.debuffable:AddDebuff("buff_madnesslogoutpenalty", "buff_madnesslogoutpenalty")
        end
    end

    -- Register as global command accessible from console
    GLOBAL.c_dologoutpenalty = c_dologoutpenalty
end

-- Make an easier resurrection command
function c_rez()
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and player:HasTag("playerghost") then
        SuUsed("c_rez", true)
        
        player:PushEvent("respawnfromghost")
    end
end

-- Register as global command accessible from console
GLOBAL.c_rez = c_rez

-- Make it easier to go to caves
function c_gocave()
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_gocave", true)
        
        GLOBAL.c_give("pickaxe")
        GLOBAL.c_gonext("cave_entrance")
    end
end

-- Register as global command accessible from console
GLOBAL.c_gocave = c_gocave

-- Make it easier to give a health penalty
function c_setpenalty(amount)
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and player.components.health ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_setpenalty", true)
        
        player.components.health:SetPenalty(amount)
    end
end

-- Register as global command accessible from console
GLOBAL.c_setpenalty = c_setpenalty

function c_revealmap()
    SuUsed("c_revealmap", true)

    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and player.player_classified ~= nil and player.player_classified.MapExplorer ~= nil then
        for x = -1600, 1600, 35 do
            for y = -1600, 1600, 35 do
                player.player_classified.MapExplorer:RevealArea(x, 0, y)
            end
        end
    end
end

-- Register as global command accessible from console
GLOBAL.c_revealmap = c_revealmap
