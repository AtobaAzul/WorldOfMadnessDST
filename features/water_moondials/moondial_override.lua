-- Imports
local TUNING = GLOBAL.TUNING

local function SetMoonDialState(inst, state, value)
    if inst ~= nil and inst.components.watersource ~= nil then
        if state == true then
            inst:AddTag("watersource")
            inst.components.watersource.available = true
            inst.components.watersource.override_fill_uses = value
        else
            inst:RemoveTag("watersource")
            inst.components.watersource.available = false
            inst.components.watersource.override_fill_uses = 0
        end
    end
end

local function onuseaswatersource(inst)
    if inst ~= nil then
        inst:DoTaskInTime(0.1, function(inst)
            if inst ~= nil and inst.components.watersource ~= nil and GLOBAL.TheWorld.state ~= nil and GLOBAL.TheWorld.state.moonphase ~= "full" then
                SetMoonDialState(inst, false)
                inst.AnimState:PlayAnimation("wane_to_new")
                inst:DoTaskInTime(1, function(inst)
                    if inst ~= nil then
                        inst.used = true
                        inst.AnimState:PlayAnimation("idle_new")
                    end
                end)
            end
        end)
    end
end

local function OnCycleChange(inst)
    if inst ~= nil then
        inst:DoTaskInTime(0.1, function(inst)
            if inst ~= nil and inst.components.watersource ~= nil and GLOBAL.TheWorld.state ~= nil then

                if GLOBAL.TheWorld.state.moonphase == "full" then
                    SetMoonDialState(inst, true, TUNING.WATERINGCAN_USES)
                elseif GLOBAL.TheWorld.state.moonphase == "threequarter" then
                    SetMoonDialState(inst, true, TUNING.WATERINGCAN_USES / 2)
                elseif GLOBAL.TheWorld.state.moonphase == "half" then
                    SetMoonDialState(inst, true, TUNING.WATERINGCAN_USES / 4)
                elseif GLOBAL.TheWorld.state.moonphase == "quarter" then
                    SetMoonDialState(inst, true, TUNING.WATERINGCAN_USES / 8)
                -- New, Invalid states
                else
                    SetMoonDialState(inst, false)
                end
        
                if inst.used == true then
                    inst.used = false
                    inst.sg:GoToState("next")
                end
        
            end
        end)
    end
end

AddPrefabPostInit("moondial", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    if inst.components.watersource == nil then
        inst:AddComponent("watersource")
    end

    inst.used = false
    SetMoonDialState(inst, false)
    inst.components.watersource.onusefn = onuseaswatersource
    inst:WatchWorldState("cycles", OnCycleChange)
end)
