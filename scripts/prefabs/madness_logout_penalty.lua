-------------------------------------------------------------------------
---------------------- Attach and dettach functions ---------------------
-------------------------------------------------------------------------

local function ApplyPenalty(inst, target)
    if inst.penaltyAmount == nil and target.components.health ~= nil and not target:HasTag("playerghost") then
        local currentPenalty = target.components.health:GetPenaltyPercent()
        local newPenalty = currentPenalty + TUNING.MADNESS.LOGOUT_PENALTY_VALUE

        if newPenalty > TUNING.MAXIMUM_HEALTH_PENALTY then
            newPenalty = TUNING.MAXIMUM_HEALTH_PENALTY
        end

        inst.penaltyAmount = newPenalty - currentPenalty
        inst.healthToRestore = math.max(0, target.components.health:GetPercent() - (1 - newPenalty))
        target.components.health:SetPenalty(newPenalty)
    end
end

local function ExtendPenalty(inst, target)
end

local function RemovePenalty(inst, target)
    if inst.penaltyAmount ~= nil and inst.healthToRestore ~= nil and target.components.health ~= nil then
        target.components.health:SetPenalty(target.components.health:GetPenaltyPercent() - inst.penaltyAmount)
        target.components.health:SetPercent(target.components.health:GetPercent() + inst.healthToRestore)
        inst.penaltyAmount = nil
        inst.healthToRestore = 0
    end
end

local function OnTimerDone(inst, data)
    if data.name == "buffover" then
        inst.components.debuff:Stop()
    end
end

local function MakeBuff(name, onattachedfn, onextendedfn, ondetachedfn, duration, priority, prefabs)

    local function OnAttached(inst, target)
        inst.entity:SetParent(target.entity)
        inst.Transform:SetPosition(0, 0, 0) --in case of loading
        inst:ListenForEvent("death", function()
            inst.components.debuff:Stop()
        end, target)

        if onattachedfn ~= nil then
            onattachedfn(inst, target)
        end
    end

    local function OnExtended(inst, target)
        inst.components.timer:StopTimer("buffover")
        inst.components.timer:StartTimer("buffover", duration)

        if onextendedfn ~= nil then
            onextendedfn(inst, target)
        end
    end

    local function OnDetached(inst, target)
        if ondetachedfn ~= nil then
            ondetachedfn(inst, target)
        end

        inst:Remove()
    end

    local function onsave(inst, data)
        data.penaltyAmount = inst.penaltyAmount
        data.healthToRestore = inst.healthToRestore
    end

    local function onload(inst, data)
        if data ~= nil then 
            inst.penaltyAmount = data.penaltyAmount
            inst.healthToRestore = data.healthToRestore
        end
    end

    local function fn()
        local inst = CreateEntity()

        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()

        --[[Non-networked entity]]
        --inst.entity:SetCanSleep(false)
        inst.entity:Hide()
        inst.persists = false

        inst.penaltyAmount = nil
        inst.healthToRestore = 0
        inst.OnSave = onsave
        inst.OnLoad = onload

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff:SetDetachedFn(OnDetached)
	    inst.components.debuff.keepondespawn = true
		
	    inst:AddComponent("timer")
        inst.components.timer:StartTimer("buffover", duration)
        inst:ListenForEvent("timerdone", OnTimerDone)

        return inst
    end

    return Prefab("buff_"..name, fn, nil, prefabs)
end

return MakeBuff("madnesslogoutpenalty", ApplyPenalty, ExtendPenalty, RemovePenalty, TUNING.MADNESS.LOGOUT_PENALTY_DURATION, 1)
