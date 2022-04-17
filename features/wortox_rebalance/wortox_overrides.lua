-- Imports
modimport("features/wortox_rebalance/constants.lua")
local FindPlayersInRange = GLOBAL.FindPlayersInRange
local TUNING = GLOBAL.TUNING

-- Uncompromising Mod Soul Override
local function AddOrRemoveTag(prefab, addOrRemove, tagName)
    AddPrefabPostInit(prefab, function(inst)
        if GLOBAL.TheWorld.ismastersim and inst ~= nil then

            if addOrRemove == "add" then
                inst:AddTag(tagName)
            elseif addOrRemove == "remove" then
                inst:RemoveTag(tagName)
            end

        end
    end)
end

-- Restore Souls
for k, v in pairs(WORTOX_RESTORE_SOULS) do
    AddOrRemoveTag(v, "remove", "soulless")
end

-- Remove Veggie Tag, Restoring Souls
-- I get where Uncompromising Mode was going with this, but it makes more sense to me to have the veggie tag off these prefabs
for k, v in pairs(WORTOX_REMOVE_VEGGIE_TAG) do
    AddOrRemoveTag(v, "remove", "veggie")
end

-- Remove Souls
for k, v in pairs(WORTOX_REMOVE_SOULS) do
    AddOrRemoveTag(v, "add", "soulless")
end

-- Helper Functions
local function OnWortoxEatFn(inst, data)
    if inst ~= nil and inst.components.health ~= nil and inst.components.sanity ~= nil and data.food and data.food.prefab ~= nil then
        -- Food Buffs
        if data.food.prefab == "green_cap_cooked" then
            inst.components.sanity:DoDelta(TUNING.SANITY_SMALL)
        elseif data.food.prefab == "blue_cap_cooked" then
            inst.components.sanity:DoDelta(TUNING.SANITY_MED)
        elseif data.food.prefab == "cookedmonstermeat" or data.food.prefab == "cookedmonstersmallmeat" then
            inst.components.health:DoDelta(TUNING.HEALING_SMALL * 3)
            inst.components.sanity:DoDelta(math.floor(TUNING.SANITY_SMALL / 3))
        elseif data.food.prefab == "monstermeat_dried" or data.food.prefab == "monstersmallmeat_dried" then
            inst.components.health:DoDelta(TUNING.HEALING_SMALL)
            inst.components.sanity:DoDelta(TUNING.SANITY_SMALL)
        elseif data.food.prefab == "monstermeat" or data.food.prefab == "monstersmallmeat" then
            inst.components.health:DoDelta(TUNING.HEALING_SMALL)
        elseif data.food.prefab == "monsterlasagna" or data.food.prefab == "monsteregg" then
            inst.components.health:DoDelta(TUNING.HEALING_SMALL)

        elseif data.food.components.edible ~= nil then
            inst.components.sanity:DoDelta(data.food.components.edible:GetSanity(inst))
        end
    end
end

local function OnWortoxEatSoulFn(inst)
    -- Remove the default buff (MEDSMALL hunger and TINY sanity)
    inst.components.hunger:DoDelta(-TUNING.CALORIES_MEDSMALL + SOUL_EAT_HUNGER_BUFF)
    inst.components.sanity:DoDelta(TUNING.SANITY_TINY - SOUL_EAT_SANITY_DEBUFF)
end

-- Overflow of souls have two scenarios: dropping them and getting them through a new item
local function IsSoul(item)
    return item.prefab == "wortox_soul"
end

local function GetStackSize(item)
    return item.components.stackable ~= nil and item.components.stackable:StackSize() or 1
end

local function OnWortoxDropItemFn(inst, data)
    if data.item ~= nil and IsSoul(data.item) and not inst.components.health:IsDead() and not inst:HasTag("playerghost") then
        inst.components.hunger:DoDelta(-SOUL_HEAL_HUNGER_DEBUFF * GetStackSize(data.item))
    end
end

local function OnWortoxSoulOverloadFn(inst)
    if not inst.components.health:IsDead() and not inst:HasTag("playerghost") then
        inst.components.hunger:DoDelta(-SOUL_HEAL_HUNGER_DEBUFF * math.floor(TUNING.WORTOX_MAX_SOULS / 2))
    end
end

-- Immunity to Sanity Aura
local function IsImmuneToWortoxSanityAura(player)
    if player ~= nil and player.prefab ~= nil then

        for k, v in pairs(WORTOX_SANITY_DEBUFF_IMMUNE_CHARACTERS) do
            if v == player.prefab then
                return true
            end
        end
        
        return false
    end

    -- Nil object passed, make immune
    return true
end

-- Sanity Aura Function
local function UpdateTickCount(inst)
    inst.madnessSanityDebuffTickCount = inst.madnessSanityDebuffTickCount + 1
    if inst.madnessSanityDebuffTickCount > WORTOX_SANITY_MAX_TICKCOUNT then
        inst.madnessSanityDebuffTickCount = 1
    end
end

local function ApplyWortoxSanityAura(inst, range, gain, loss, threshold)
    if inst == nil or inst.components.sanity == nil or inst.components.health:IsDead() or inst:HasTag("playerghost") then
        return
    end

    -- Only activate at a certain sanity threshold
    if inst.components.sanity:GetPercent() >= threshold then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, range, true)
    local filtered_players = {}
    local sanityGradientSlope = (-WORTOX_SANITY_MAX_TICKCOUNT) / (1 - WORTOX_SANITY_MIN_PERCENT)
    local sanityGradientStart = -sanityGradientSlope

    -- Filter through the player list
    -- 1. Not the inst player
    -- 2. Player is not immune to the aura
    -- 3. Player has more than 0 sanity
    for i, player in ipairs(players) do
        if player ~= nil and player ~= inst and not IsImmuneToWortoxSanityAura(player) and player.components.sanity ~= nil and player.components.sanity:GetPercent() > 0 then
            table.insert(filtered_players, player)
        end
    end

    -- Sanity debuff for any player near Wortox
    for i, player in ipairs(filtered_players) do
        if ((player.components.sanity:GetPercent() * sanityGradientSlope) + sanityGradientStart) < inst.madnessSanityDebuffTickCount then
            inst.components.sanity:DoDelta(gain)
            player.components.sanity:DoDelta(-loss)
        end
    end
end

-- Wortox Player Changes
AddPlayerPostInit(function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end
  
    if inst ~= nil and inst.prefab == "wortox" then

        -- Max health override for uncompromising mod
        if inst.components.health ~= nil then
            inst.components.health:SetMaxHealth(TUNING.WORTOX_HEALTH)
        end

        -- Override IsNear Function
        -- Hacky way for IsNear function to detect a soul by using a unique ID for range
        local originalIsNear = inst.IsNear
        function inst:IsNear(otherinst, dist)
            if dist == TUNING.WORTOX_SOULEXTRACT_RANGE then
                return true
            else
                return originalIsNear(self, otherinst, dist)
            end
        end

        -- Wortox Event Listeners
        inst:ListenForEvent("oneat", OnWortoxEatFn)
        inst:ListenForEvent("oneatsoul", OnWortoxEatSoulFn)
        inst:ListenForEvent("dropitem", OnWortoxDropItemFn)
        inst:ListenForEvent("souloverload", OnWortoxSoulOverloadFn)

        -- Wortox Santiy Aura
        inst.madnessSanityDebuffTickCount = 1
        inst:DoPeriodicTask(1, UpdateTickCount)
        inst:DoPeriodicTask(WORTOX_LARGE_SANITY_DEBUFF_FREQUENCY, ApplyWortoxSanityAura, nil, WORTOX_LARGE_SANITY_DEBUFF_RANGE, WORTOX_LARGE_SANITY_DEBUFF_GAIN, WORTOX_LARGE_SANITY_DEBUFF_LOSS, WORTOX_LARGE_SANITY_DEBUFF_THRESHOLD)
  
    end
end)
