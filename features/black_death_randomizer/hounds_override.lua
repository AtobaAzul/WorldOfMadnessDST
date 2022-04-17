-- Imports
local SpawnPrefab = GLOBAL.SpawnPrefab

-- Fix Hounds
-- Only default hounds transform in vanilla, so we'll keep it the same way here
-- Uncompromising mode hounds don't have a transform animation, so we only override normal hounds
local function houndDeath(inst)
    if inst.components.tiddlevirus ~= nil and inst.components.tiddlevirus.active == true then
        local x, y, z = inst.Transform:GetWorldPosition()
        local type = inst:IsOnOcean() and "tiddle_decay_ocean" or "tiddle_decay"
        local corpse = SpawnPrefab(type)

        corpse.Transform:SetPosition(x + math.random() * 1.25 - 1.25 / 1.25, y, z + math.random() * 1.25 - 1.25 / 1.25)
    end
end

AddPrefabPostInit("hound", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    -- Overwrite hounds mutation code
    inst._CanMutateFromCorpse = function()
        if (inst.components.amphibiouscreature == nil or not inst.components.amphibiouscreature.in_water)
		and GLOBAL.TheWorld.Map:IsVisualGroundAtPoint(inst.Transform:GetWorldPosition()) then
            local node = GLOBAL.TheWorld.Map:FindNodeAtPoint(inst.Transform:GetWorldPosition())

            local lunar = node ~= nil and node.tags ~= nil and table.contains(node.tags, "lunacyarea")
            local bogs = node ~= nil and node.tags ~= nil and table.contains(node.tags, "Mist") and table.contains(node.tags, "nohunt")

            local area_spawn_chance = ((math.random() <= TUNING.MUTATEDHOUND_SPAWN_CHANCE) and (lunar or bogs))
            local infected = (inst.components.tiddlevirus ~= nil and inst.components.tiddlevirus.active == true)

            return area_spawn_chance or infected
        end

        return false
    end

    -- The plague glob does not spawn on death if the hound transforms so we manually spawn it here
    inst:ListenForEvent("death", houndDeath)
end)
