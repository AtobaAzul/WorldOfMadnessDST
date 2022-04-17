-- Imports
local TUNING = GLOBAL.TUNING

-- Bird Cages don't offer any food preservation
TUNING.PERISH_CAGE_MULT = 1


-- Birdcage food
local function BirdcageGetBird(inst)
    return (inst.components.occupiable and inst.components.occupiable:GetOccupant()) or nil
end
  
AddPrefabPostInit("birdcage", function(inst)
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    if inst.components.trader ~= nil and inst.components.trader.test ~= nil then
        local originalAcceptTestFn = inst.components.trader.test
        inst.components.trader.test = function(inst, item)
            if IsMonsterFood(item.prefab) then
                -- Crows get an exception when starved
                local bird = BirdcageGetBird(inst)
                if bird ~= nil and bird.prefab == "crow" and inst.components.inspectable ~= nil and inst.components.inspectable.getstatus(inst) == "STARVING" then
                    return true
                end
                return false
            else
                return originalAcceptTestFn(inst, item)
            end
        end
    end
end)
