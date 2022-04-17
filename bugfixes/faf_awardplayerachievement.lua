-- Imports
local TUNING = GLOBAL.TUNING
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
local GetRandomWithVariance = GLOBAL.GetRandomWithVariance
local AwardPlayerAchievement = GLOBAL.AwardPlayerAchievement

local plantpinecone = nil

local function OnDeployPinecone(inst, pt, deployer)
    if inst ~= nil and inst.components.stackable ~= nil and plantpinecone ~= nil then
        
        local timeToGrow = GetRandomWithVariance(TUNING.PINECONE_GROWTIME.base, TUNING.PINECONE_GROWTIME.random)
        inst = inst.components.stackable:Get()
        inst.Physics:Teleport(pt:Get())
        plantpinecone(inst, timeToGrow)

        --tell any nearby leifs to chill out
        local ents = GLOBAL.TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.LEIF_PINECONE_CHILL_RADIUS, { "leif" })

        local played_sound = false
        for i, v in ipairs(ents) do
            local chill_chance =
                v:GetDistanceSqToPoint(pt:Get()) < TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS * TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS and
                TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE or
                TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR

            if math.random() < chill_chance then
                if v.components.sleeper ~= nil then
                    v.components.sleeper:GoToSleep(1000)
                    if deployer ~= nil then
                        AwardPlayerAchievement("pacify_forest", deployer)
                    end
                end

            elseif not played_sound then
                if v.SoundEmitter ~= nil then
                    v.SoundEmitter:PlaySound("dontstarve/creatures/leif/taunt_VO")
                    played_sound = true
                end
            end
        end

    end
end

local function applyFAFFix(prefab)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim or inst == nil then
            return
        end

        if inst.components.deployable ~= nil then
            if plantpinecone == nil then
                plantpinecone = UpvalueHacker.GetUpvalue(inst.components.deployable.ondeploy, "plantpinecone")
            end
            
            inst.components.deployable.ondeploy = OnDeployPinecone
        end
    end)
end

applyFAFFix("twiggy_nut")
applyFAFFix("pinecone")
