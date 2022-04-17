-- Imports
local AllPlayers = GLOBAL.AllPlayers

-- Prevent Soul Throw from missing
local function SeekSoulStealer(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local closestPlayer = nil
    local rangesq = nil
    for i, v in ipairs(AllPlayers) do
        if v:HasTag("soulstealer") and
            not (v.components.health:IsDead() or v:HasTag("playerghost")) and
            not (v.sg ~= nil and (v.sg:HasStateTag("nomorph") or v.sg:HasStateTag("silentmorph"))) and
            v.entity:IsVisible() then
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            if rangesq == nil or distsq < rangesq then
                rangesq = distsq
                closestPlayer = v
            end
        end
    end
    if closestPlayer ~= nil then
        inst._soulretrycount = 0
        inst.components.projectile:Throw(inst, closestPlayer, inst)
    else
        -- If target is not found, keep retrying
        inst._soulretrycount = inst._soulretrycount + 1
        if inst._soulretrycount <= 60 then
            inst:DoTaskInTime(1, SeekSoulStealer)
        else
            inst.components.projectile:Miss(inst.components.projectile.target)
        end
    end
end

local function OnSoulThrowTimeout(inst)
    inst._timeouttask = nil
    -- Throw the soul again on timeout
    SeekSoulStealer(inst)
end

local function OnThrowSoul(inst)
    if inst._timeouttask ~= nil then
        inst._timeouttask:Cancel()
    end
    inst._timeouttask = inst:DoTaskInTime(0.5, OnSoulThrowTimeout)
    if inst._seektask ~= nil then
        inst._seektask:Cancel()
        inst._seektask = nil
    end
    inst.AnimState:Hide("blob")
    inst._hastail:set(true)
end


AddPrefabPostInit(
  "wortox_soul_spawn",
  function(inst)
    if not GLOBAL.TheWorld.ismastersim then
      return
    end

    inst._soulretrycount = 0
    inst.components.projectile:SetOnThrownFn(OnThrowSoul)
    inst._seektask = inst:DoTaskInTime(0.5, OnThrowSoul)
end)
