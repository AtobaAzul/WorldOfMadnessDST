-- Imports
local CONSTRUCTION_PLANS = GLOBAL.CONSTRUCTION_PLANS
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
modimport("features/newboatshapes_increase_cost/constants.lua")

local function calculateBoardCost(area)
    return math.ceil(NEW_BOAT_SHAPES_INCREASE_COST_BASE ^ area)
end

local function NewSetConstructionCost(inst, area)
    CONSTRUCTION_PLANS[inst.prefab] = {Ingredient("boards", calculateBoardCost(area))}
end

AddPrefabPostInit("shipyard_builder", function(inst)
    if inst == nil then
        return
    end

    -- Prefab Hack since all instances of this entity behave differently
    inst.prefab = tostring(inst.prefab) .. tostring(inst.GUID)

    if not GLOBAL.TheWorld.ismastersim then
        -- Client-side hack: there's a bug in the mod
        -- ListenForEvent registers an empty function
        -- as the function is called and not passed to ListenForEvent
        -- To fix this, I'm calling the function 0.1 seconds after the mod does
        -- Given that ListenForEvent does nothing, no need to override it.
        inst:DoTaskInTime(0.1, function()
			NewSetConstructionCost(inst, inst.area:value())
		end)
    else
        UpvalueHacker.SetUpvalue(inst.OnLoad, NewSetConstructionCost, "SetConstructionCost")
    end
end)

AddPrefabPostInit("shipyard_builder_item", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    UpvalueHacker.SetUpvalue(inst.components.deployable.ondeploy, NewSetConstructionCost, "SetConstructionCost")
end)

AddPrefabPostInit("boat_custom", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    local originalConstructData = inst.construct_data
    inst.construct_data = function(inst, draw_vertices, vertices, cuts, area, radius)
        local data = originalConstructData(inst, draw_vertices, vertices, cuts, area, radius)
        data.loot.boards = calculateBoardCost(area)
        return data
    end
end)
