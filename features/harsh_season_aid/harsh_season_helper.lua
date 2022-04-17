-- Imports
local Ents = GLOBAL.Ents
local SEASONS = GLOBAL.SEASONS
local AllPlayers = GLOBAL.AllPlayers
local SpawnPrefab = GLOBAL.SpawnPrefab
modimport("features/harsh_season_aid/constants.lua")

local portal_instance = nil
local portal_firepit = nil

local function OnFuelChange(inst, data)
    if inst ~= nil and inst.components.fueled ~= nil and data.percent ~= nil then
        if data.percent ~= 0 and data.percent ~= HELPER_FIREPIT_INTENSITY then
            inst.components.fueled:SetPercent(HELPER_FIREPIT_INTENSITY)
        end
    end
end

local function SetFire(firepit, phase)
    if firepit ~= nil then

        -- Effect Type
        local fx = nil
        local x, y, z = firepit.Transform:GetWorldPosition()
        local cold_tag = ""
        if firepit.prefab == "coldfirepit" then
            cold_tag = "_cold"
        end

        if phase == "night" then
            firepit.SoundEmitter:PlaySound("dontstarve_DLC001/summer/smolder", "smolder")
            firepit.components.fueled:SetPercent(0)

            -- Special effects
            fx = SpawnPrefab("halloween_firepuff" .. cold_tag .. "_1")
            if fx ~= nil then
                fx.Transform:SetPosition(x, y, z)
            end
            fx = SpawnPrefab("lavaarena_creature_teleport_smoke_fx_1")
            if fx ~= nil then
                fx.Transform:SetPosition(x, y, z)
            end

            -- Special effects if Global Positions is on
            if IsGlobalPositionsEnabled() and firepit.components.smokeemitter ~= nil then
                firepit.components.smokeemitter:Enable(30)
            end
        elseif phase == "day" then
            firepit.SoundEmitter:KillSound("smolder")
            firepit.components.fueled:SetPercent(HELPER_FIREPIT_INTENSITY)

            -- Special effects
            fx = SpawnPrefab("halloween_firepuff" .. cold_tag .. "_3")
            if fx ~= nil then
                fx.Transform:SetPosition(x, y, z)
            end

            -- Special effects if Global Positions is on
            if IsGlobalPositionsEnabled() and firepit.components.smokeemitter ~= nil then
                firepit.components.smokeemitter:Disable()
            end
        end

    end
end

local function FindSpawnPoint()
    for k, ent in pairs(Ents) do
        if ent.prefab == "multiplayer_portal_moonrock" then
            return ent
        elseif ent.prefab == "multiplayer_portal_moonrock_constr" then
            return ent
        elseif ent.prefab == "multiplayer_portal" then
            return ent
        end
    end

    return nil
end

local function SpawnFirePit(inst, player, season)
    local firepit

    -- Check portal instance
    if portal_instance == nil or not portal_instance:IsValid() then
        portal_instance = FindSpawnPoint()
    end

    if portal_instance ~= nil and portal_instance:IsValid() then
        local x, y, z = portal_instance.Transform:GetWorldPosition()
        x = x + math.random(-8,8)
        z = z + math.random(-8,8)

        if season == "winter" then
            firepit = SpawnWithEffect("firepit", x, y, z, true, "firepit_fanged", player)
        elseif season == "summer" then
            firepit = SpawnWithEffect("coldfirepit", x, y, z, true, nil, player)
        end

        -- In case something goes wrong with the spawning
        if firepit ~= nil then
            -- Special effects if Global Positions is on
            if IsGlobalPositionsEnabled() and firepit.components.smokeemitter == nil then
                firepit:AddComponent("smokeemitter")
            end

            firepit.components.fueled.accepting = false
            firepit.components.fueled:SetPercent(HELPER_FIREPIT_INTENSITY)
            firepit.components.workable:SetWorkable(false)
            firepit.components.lootdropper.GenerateLoot = function(self) return {"ash"} end
            firepit:ListenForEvent("percentusedchange", OnFuelChange)
        end
    end

    return firepit
end

local function DestroyFirePit(firepit, player)
    if firepit ~= nil then
        firepit.SoundEmitter:KillSound("smolder")
        firepit.components.workable.onfinish(firepit, player)
    end
end

-- On Phase Change
local function OnPhaseChange(inst, phase)
    SetFire(portal_firepit, phase)
end

local function OnSeasonChange(inst, data)
    local season = data.season

    if season ~= nil then
        -- For skin purposes
        -- randomPlayer can safely be nil
        local randomPlayer
        if #AllPlayers > 0 then
            randomPlayer = AllPlayers[math.random(1, #AllPlayers)]
        end

        if season == SEASONS.AUTUMN then
            DestroyFirePit(portal_firepit, randomPlayer)
            portal_firepit = nil
        elseif season == SEASONS.WINTER then
            portal_firepit = SpawnFirePit(inst, randomPlayer, "winter")
        elseif season == SEASONS.SPRING then
            DestroyFirePit(portal_firepit, randomPlayer)
            portal_firepit = nil
        elseif season == SEASONS.SUMMER then
            portal_firepit = SpawnFirePit(inst, randomPlayer, "summer")
        end
    end
end

local function OnNewPlayerSpawn(inst, player)
    if player ~= nil then

        local items = {}
        local equips = {}

        if GLOBAL.TheWorld.state.iswinter then
            table.insert(items, SpawnPrefab("heatrock", "heatrock_fire", nil, player.userid))
            table.insert(equips, SpawnPrefab("earmuffshat"))
        elseif GLOBAL.TheWorld.state.isspring then
            table.insert(equips, SpawnPrefab("umbrella"))
        elseif GLOBAL.TheWorld.state.issummer then
            table.insert(items, SpawnPrefab("heatrock", "heatrock_fire", nil, player.userid))
            table.insert(equips, SpawnPrefab("strawhat"))
        end

        for k, item in pairs(items) do
            if item ~= nil then
                if item.components.fueled ~= nil then
                    item.components.fueled:SetPercent(HELPER_ITEM_DURABILITY)
                end
                player.components.inventory:GiveItem(item)
            end
        end

        for k, equip in pairs(equips) do
            if equip ~= nil then
                if equip.components.fueled ~= nil then
                    equip.components.fueled:SetPercent(HELPER_ITEM_DURABILITY)
                end
                player.components.inventory:Equip(equip)
            end
        end

    end
end

-- Fetch a reference to the spawn point in play
local SPAWN_POINTS = {
    "multiplayer_portal_moonrock",
    "multiplayer_portal_moonrock_constr",
    "multiplayer_portal"
}

local function FetchReferenceToSpawnPoints(prefab)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
    
        if inst ~= nil then
            portal_instance = inst
        end
    end)
end
  
for k, v in pairs(SPAWN_POINTS) do
    FetchReferenceToSpawnPoints(v)
end

-- World events
AddSimPostInit(function()

    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- The following must only trigger on the master shard
    if IsMasterShard() then
        -- Capture Join event of a new player
        GLOBAL.TheWorld:ListenForEvent("ms_newplayerspawned", OnNewPlayerSpawn)

        -- Capture Phase change
        GLOBAL.TheWorld:ListenForEvent("phasechanged", OnPhaseChange)

        -- Capture Season change
        GLOBAL.TheWorld:ListenForEvent("madness_seasonchanged", OnSeasonChange)
    end

end)
