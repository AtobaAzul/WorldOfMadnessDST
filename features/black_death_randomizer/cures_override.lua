-- Imports
local Ents = GLOBAL.Ents
local TUNING = GLOBAL.TUNING
local Action = GLOBAL.Action
local ACTIONS = GLOBAL.ACTIONS
local STRINGS = GLOBAL.STRINGS
local DEGREES = GLOBAL.DEGREES
local Prefabs = GLOBAL.Prefabs
local GetString = GLOBAL.GetString
local SpawnPrefab = GLOBAL.SpawnPrefab
local cooking = GLOBAL.require("cooking")
local ActionHandler = GLOBAL.ActionHandler
local BufferedAction = GLOBAL.BufferedAction
local GetRandomMinMax = GLOBAL.GetRandomMinMax
local AddIngredientValues = GLOBAL.AddIngredientValues
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
modimport("features/black_death_randomizer/constants.lua")

-- Change the way cures work
table.insert(STRINGS.TIDDLE_MEDICINE, "The \"Cure\"")
STRINGS.NAMES.TIDDLE_FAKECURE = "Refined Plague Extract"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TIDDLE_FAKECURE = "I didn't know the plague could be refined..."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TIDDLE_FAKECURE = "The bottle looks more refined... sure..."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TIDDLE_FAKECURE = "Such a colourful concoction. Maybe I can use this?"
STRINGS.CHARACTERS.WENDY.DESCRIBE.TIDDLE_FAKECURE = "Abigail doesn't like it."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.TIDDLE_FAKECURE = "Mmmm. Smells fruity."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.TIDDLE_FAKECURE = "I wonder if I can make things with it."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.TIDDLE_FAKECURE = "Less icky..."
STRINGS.CHARACTERS.WURT.DESCRIBE.TIDDLE_FAKECURE = "Are those bubbles?"
STRINGS.CHARACTERS.WARLY.DESCRIBE.TIDDLE_FAKECURE = "Ahh! A new dish's secret ingredient perhaps?"
STRINGS.CHARACTERS.WORTOX.DESCRIBE.TIDDLE_FAKECURE = "I'm not sure how I feel about this..."
STRINGS.CHARACTERS.WINONA.DESCRIBE.TIDDLE_FAKECURE = "The color... the viscosity... yes this gives me ideas!"
AddIngredientValues({"tiddlecure"}, {inedible=1, magic=1})

local GENERATED_COOKABLE_PREFABS
TUNING.TIDDLEVIRUS_MAX = 168 -- Roughly 14 days
TUNING.BLOODLETTING_CUREAMOUNT = 0
TUNING.BLOODLETTING_STINGER_CUREAMOUNT = 0

local function GeneratePrefabList()
    local t = {}

    for name, prefab in pairs(Prefabs) do
        if cooking.IsCookingIngredient(name) and name ~= "tiddlecure" then
            table.insert(t, name)
        end
    end

    return t
end

local function findCureIngredient()
    return TableGetRandom(GENERATED_COOKABLE_PREFABS)
end

local function cureIngredientsGenerated()
    return (GLOBAL.TheWorld.state.madness_cure_ingredient1 ~= "none" and GLOBAL.TheWorld.state.madness_cure_ingredient2 ~= "none" and GLOBAL.TheWorld.state.madness_cure_ingredient3 ~= "none")
end

-- Real Cure
local OldGetRecipe = cooking.GetRecipe
cooking.GetRecipe = function(cooker, product)
    if product == "madness_realcure" or product == "madness_goodcure" or product == "madness_badcure" then
        return {}
    else
        return OldGetRecipe(cooker, product)
    end
end

local OldCalculateRecipe = cooking.CalculateRecipe
cooking.CalculateRecipe = function(cooker, names)
    if TableContains(names, "tiddlecure") then
        if TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient1) and TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient2) and TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient3) then
            return "madness_realcure", 1
        elseif TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient1) or TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient2) or TableContains(names, GLOBAL.TheWorld.state.madness_cure_ingredient3) then
            return "madness_goodcure", 1
        end

        return "madness_badcure", 1
    else
        return OldCalculateRecipe(cooker, names)
    end
end

local function onEatTiddleFakeCure(inst, eater)
    if eater ~= nil and eater.components.tiddlevirus ~= nil and eater.components.tiddlevirus.active == true and eater:HasTag("TiddleSymptoms")
    and eater.components.health ~= nil and eater:HasTag("player") then
        eater.components.tiddlevirus:DoVirus(0, true)
	    eater.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
        SpawnPrefab("chester_transform_fx").Transform:SetPosition(eater:GetPosition():Get())
    end
end

local function applyCure(eater, cure_amount, health_amount, sanitycost)
    if eater ~= nil and eater.components.health ~= nil and not eater.components.health:IsDead() then

        if eater.components.tiddlevirus ~= nil and eater.components.tiddlevirus.active == true and eater:HasTag("TiddleSymptoms") then

            eater.components.health:DeltaPenalty(-cure_amount * 0.005)
            eater.components.health:DoDelta(health_amount)
            eater.components.tiddlevirus.sanityvalue = math.clamp(eater.components.tiddlevirus.sanityvalue - (cure_amount * 0.005), 0, 0.5)
            eater.components.tiddlevirus:DoVirus(0, true)

            if eater.components.sanity ~= nil then
                eater.components.sanity:DoDelta(sanitycost)
            end

            if eater:HasTag("player") then
                if health_amount < 0 then
                    eater.sg:GoToState("tiddle_cough")
                    if eater.components.talker ~= nil and not eater:HasTag("mime") then
                        eater.components.talker:Say(GetString(eater, "ANNOUNCE_TIDDLEMEDS"))
                    end
                else
                    if eater.components.talker ~= nil and not eater:HasTag("mime") then
                        eater.components.talker:Say(GetString(eater, "ANNOUNCE_TIDDLENOTCURED"))
                    end
                end
            end

            SpawnPrefab("chester_transform_fx").Transform:SetPosition(eater:GetPosition():Get())
            eater.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")

        end

    end
end

local function onEatBadCure(inst, eater)
    applyCure(eater, inst.cure_amount, inst.health_amount, inst.sanitycost)
    inst:Remove()
end

local function onEatGoodCure(inst, eater)
    if inst.cure_amount < 0 then inst.cure_amount = inst.cure_amount * -1 end
    if inst.health_amount < 0 then inst.health_amount = inst.health_amount * -1 end
    if inst.sanitycost < 0 then inst.sanitycost = inst.sanitycost * -1 end

    applyCure(eater, inst.cure_amount, inst.health_amount, inst.sanitycost)
    inst:Remove()
end

local function onEatRealCure(inst, eater)
    if eater ~= nil and eater.components.tiddlevirus ~= nil and eater.components.tiddlevirus.active == true then
        local hasSymptoms = eater:HasTag("TiddleSymptoms")
        eater.components.tiddlevirus:StopVirus()

        if hasSymptoms then
            if eater.components.health ~= nil then
                eater.components.health:DeltaPenalty(-1)
                eater.components.health:DoDelta(100)
            end
    
            if eater.components.sanity ~= nil then
                eater.components.sanity:DoDelta(75)
            end

            SpawnPrefab("chester_transform_fx").Transform:SetPosition(eater:GetPosition():Get())
    
            if eater.prefab == "pigman" then
                local chatlines = "TIDDLEDOC_TALK_CURED"
                local strtbl = STRINGS[chatlines]
                if strtbl ~= nil then
                    local strid = math.random(#strtbl)
                    if eater.components.talker ~= nil then
                        eater.components.talker:Chatter(chatlines, strid)
                    end
                end
    
                if eater.doctor ~= nil then
                    eater.doctor:PushEvent("patienttreated", "TIDDLEDOC_TALK_SUCCESS")
                    eater.doctor = nil
                end
                inst:Remove()
    
            elseif eater:HasTag("player") then
                eater.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")
                if eater.components.talker ~= nil and not eater:HasTag("mime") then
                    eater.components.talker:Say(GetString(eater, "ANNOUNCE_TIDDLECURED"))
                end
            end
        end

   end
end

local function SetOnEatFn(prefab, oneatfn)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim or inst == nil then
            return
        end

        -- Recalculate the med properties
        if prefab ~= "tiddle_fakecure" then
            local goodness = 1
            if math.random() < VIRUS_MED_BAD_CHANCE then
                goodness = -1
            end
        
            local ratio = GetRandomMinMax(0.2, 0.8)
            inst.health_amount = (GetRandomMinMax(TUNING.TIDDLEMEDS_MINHEALTH, TUNING.TIDDLEMEDS_MAXHEALTH) * ratio) * goodness
            inst.cure_amount = (GetRandomMinMax(TUNING.TIDDLEMEDS_MINCURE, TUNING.TIDDLEMEDS_MAXCURE) * (1 - ratio)) * goodness
            inst.sanitycost = (GetRandomMinMax(1, TUNING.TIDDLEMEDS_SANITYCOST) * ratio) * goodness
        end

        if inst.components.edible ~= nil then
            inst.components.edible:SetOnEatenFn(oneatfn)
        end
    end)
end

SetOnEatFn("tiddle_fakecure", onEatTiddleFakeCure)
SetOnEatFn("madness_badcure", onEatBadCure)
SetOnEatFn("madness_goodcure", onEatGoodCure)

AddPrefabPostInit("madness_realcure", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    inst:AddTag("tiddlecurer")
    inst.AnimState:SetLightOverride(0.3)

    local decorateMedicinePrefab = UpvalueHacker.GetUpvalue(inst.OnLoad, "SetUp")

    inst.shape = GLOBAL.TheWorld.state.madness_cure_cureshape
	inst.color1 = GLOBAL.TheWorld.state.madness_cure_curecolor1
	inst.color2 = GLOBAL.TheWorld.state.madness_cure_curecolor2
    inst.color3 = GLOBAL.TheWorld.state.madness_cure_curecolor3

    if decorateMedicinePrefab ~= nil then
        decorateMedicinePrefab(inst)
    end

    if inst.components.edible ~= nil then
        inst.components.edible:SetOnEatenFn(onEatRealCure)
    end
end)

-- Make cures givable
local function GiveCureAction(act)
    if act.invobject ~= nil and act.invobject.components.edible ~= nil and act.target ~= nil and act.invobject.prefab ~= nil
    and (act.invobject.prefab == "madness_realcure" or act.invobject.prefab == "madness_badcure" or act.invobject.prefab == "madness_goodcure") then
        act.invobject.components.edible:OnEaten(act.target)
        act.invobject:Remove()
        return true
    end
end

local function GiveCureClientAction(inst, doer, target, actions, right)
    if inst ~= nil and inst.prefab ~= nil and right
    and (inst.prefab == "madness_realcure" or inst.prefab == "madness_badcure" or inst.prefab == "madness_goodcure") then
        if doer ~= target and target.components.health ~= nil then
            table.insert(actions, ACTIONS.GIVE_CURE)
        end
    end
end

local GIVE_CURE = Action({priority=10, mount_valid=true})
GIVE_CURE.str = "Cure"
GIVE_CURE.id = "GIVE_CURE"
GIVE_CURE.fn = GiveCureAction
AddAction(GIVE_CURE)
AddComponentAction("USEITEM", "edible", GiveCureClientAction)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.GIVE_CURE, "give"))
AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.GIVE_CURE, "give"))

-- Plague Doctor
local function NewMakeMedicineAction(inst)
    local target = GLOBAL.TheSim:FindFirstEntityWithTag("tiddlepiglab")

    if target ~= nil and inst.debt >= 10 then
        local shroom = inst.components.inventory:FindItem(function(item) return item.prefab == "mandrake" or item.prefab == "madness_realcure" or item.prefab == "madness_goodcure" or item.prefab == "madness_badcure" end)
        if shroom == nil then
            shroom = SpawnPrefab("madness_badcure")
            if shroom ~= nil then
                inst.components.inventory:GiveItem(shroom)
            end
        end

        return (shroom ~= nil) and BufferedAction(inst, target, ACTIONS.GIVE, shroom) or nil
    end
end

AddPrefabPostInit("tiddledoctor", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    local brainFn = inst.brainfn
    UpvalueHacker.SetUpvalue(brainFn.OnStart, NewMakeMedicineAction, "MakeMedicineAction")
    inst:SetBrain(brainFn)
end)

local function LabShouldAcceptItem(inst, item, giver)
    if (item.prefab == "madness_realcure" or item.prefab == "madness_goodcure" or item.prefab == "madness_badcure" or item.prefab:match("mandrake")) and giver.prefab == "tiddledoctor" then
        return true
    end
end

local function LabOnGetItem(inst, giver, item)
    giver:AddTag("examining")
    giver.debt = 0
    giver:DoTaskInTime(2, function()
        if giver ~= nil then
            giver:RemoveTag("examining")
        end
    end)

    local cure_ingredients = {
        GLOBAL.TheWorld.state.madness_cure_ingredient1,
        GLOBAL.TheWorld.state.madness_cure_ingredient2,
        GLOBAL.TheWorld.state.madness_cure_ingredient3
    }

    local meds_prefabs = {
        "madness_goodcure",
        "madness_badcure",
        "tiddle_fakecure",
        "wetgoop"
    }

    local iscure = item.prefab:match("mandrake") and true or false
    local count = iscure == true and 1 or 2
    local down = GLOBAL.TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) / DEGREES
    local x, y, z = inst.Transform:GetWorldPosition()
    y = 2.75

    inst.AnimState:PlayAnimation("use")
    inst.AnimState:PushAnimation("idle", false)
    inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/hit")

    if iscure == true and not giver.foundcure == true then
        inst.SoundEmitter:PlaySound("hookline_2/characters/hermit/friendship_music/10")
        giver.foundcure = true
    end

    inst:DoTaskInTime(0.475, function()
        if giver ~= nil then

            if iscure == true then
                giver.sg:GoToState("joyful")
                giver:PushEvent("patienttreated", "TIDDLEDOC_TALK_MANDRAKE", 0)

            elseif (math.random() < VIRUS_MED_HINT_CHANCE) and giver.components.talker ~= nil then
                local vowels = {"a", "e", "i", "o", "u", "y"}
                local consonants = {"b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"}
                local ingredientName = GetNameFromPrefab(TableGetRandom(cure_ingredients))

                if ingredientName ~= nil and string.len(ingredientName) >= 3 then
                    local ingredientFirstLetter = string.sub(ingredientName, 1, 2)
                    local ingredientSecondLetter = string.sub(ingredientName, 3, 3)
                    local ingredientRandomLetterTable = vowels
                    if TableContains(consonants, ingredientSecondLetter) then
                        ingredientRandomLetterTable = consonants
                    end
                    local generateSecondLetter = function()
                        return " " .. ingredientFirstLetter .. TableGetRandom(ingredientRandomLetterTable) .. "...?"
                    end

                    giver.components.talker:Say(string.upper("The special ingredient! What was it again?"), 3)
                    giver:DoTaskInTime(3, function()
                        if giver ~= nil and giver.components.talker ~= nil then
                            giver.components.talker:Say(string.upper("Yes! It started with " .. ingredientFirstLetter .. "... Was it" .. generateSecondLetter() .. generateSecondLetter() .. generateSecondLetter()), 5)
                        end
                    end)
                end
            end
            
            inst.SoundEmitter:PlaySound("dontstarve/halloween_2018/madscience_machine/finish")
            for k = 1, count do
                if iscure == true then
                    local someforme = SpawnPrefab(TableGetRandom(meds_prefabs))
                    giver.components.inventory:GiveItem(someforme)
                end

                local meds = SpawnPrefab(iscure == true and TableGetRandom(cure_ingredients) or TableGetRandom(meds_prefabs))
                if meds ~= nil then
                    meds.Transform:SetPosition(x, y, z)
                    local speed = math.random() * 2 + 2
                    local shot_angle = (angle + math.random() * 60 - 30) * DEGREES
                    meds.Physics:SetVel(speed * math.cos(shot_angle), math.random() * 4 + 8, speed * math.sin(shot_angle))
                end
            end

        end
    end)
end

AddPrefabPostInit("tiddlepiglab", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    if inst.components.trader ~= nil then
        inst.components.trader:SetAcceptTest(LabShouldAcceptItem)
        inst.components.trader.onaccept = LabOnGetItem
    end
end)

AddComponentPostInit("tiddlevirus", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    local Healthy = UpvalueHacker.GetUpvalue(self._ctor, "OnEat", "Healthy")
    local IsValidVictim = UpvalueHacker.GetUpvalue(self._ctor, "OnEat", "IsValidVictim")

    local function NewVirusOnEat(inst, data)
        local food = data.food

        if Healthy == nil then
            Healthy = function() return false end
        end
    
        if IsValidVictim == nil then
            IsValidVictim = function() return false end
        end

        if (food.components.edible.ismeat == true and food:HasTag("cookable") and not inst:HasTag("TiddleSymptoms")) and IsValidVictim(inst) then
            if (inst:HasTag("player") and math.random(0, 10) >= 0.25) or math.random(0, 10) >= 0.75 then
                if inst:HasTag("TiddleVirus") then
                    inst.components.tiddlevirus:DoVirus(1, true)
                else
                    inst.components.tiddlevirus:PushVirus(TUNING.TIDDLEVIRUS_GIANT, "food", true)
                end

                if inst:HasTag("player") then
                    inst.components.talker:Say(GetString(inst, "ANNOUNCE_EAT", "PAINFUL"))
                end
            end

        elseif food:HasTag("mushroom") then 
            inst.components.tiddlevirus:DoImmunityDelta(TUNING.TIDDLEVIRUS_IMMUNITYSMALL)

        elseif Healthy(food) then 
            inst.components.tiddlevirus:DoImmunityDelta(TUNING.TIDDLEVIRUS_IMMUNITYMED)
        end
    end

    UpvalueHacker.SetUpvalue(self._ctor, NewVirusOnEat, "OnEat")
end)

local function OnSeasonChange(inst, data)
    if GLOBAL.TheWorld.worldprefab == "forest" and math.random() < VIRUS_MANDRAKE_SPAWN_CHANCE then

        for k, ent in pairs(Ents) do
            if ent.prefab ~= nil and (ent.prefab == "mandrake_planted" or ent.prefab == "mandrake_active") then
                return
            end 
        end

        local rooms = {}
        for i, node in ipairs(GLOBAL.TheWorld.topology.nodes) do
            if (GLOBAL.TheWorld.topology.ids[i]:match("MandrakeHome")) then
                table.insert(rooms, node)
            end
        end

        local room = TableGetRandom(rooms)
        if room ~= nil then
            local x = room.x + math.random(-55, 55)
            local y = 0
            local z = room.y + math.random(-55, 55)
            SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
            SpawnPrefab("mandrake_planted").Transform:SetPosition(x, y, z)
        end

    end
end

AddComponentPostInit("worldstate", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Add a new variables to save
    self.data.madness_cure_ingredient1 = "none"
    self.data.madness_cure_ingredient2 = "none"
    self.data.madness_cure_ingredient3 = "none"

    self.data.madness_cure_cureshape = "none"
    self.data.madness_cure_curecolor1 = "none"
    self.data.madness_cure_curecolor2 = "none"
    self.data.madness_cure_curecolor3 = "none"
end)

-- World events
AddSimPostInit(function()
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- The following must only trigger on the master shard
    if IsMasterShard() then
        if not cureIngredientsGenerated() then
            GENERATED_COOKABLE_PREFABS = GeneratePrefabList()
            GLOBAL.TheWorld.state.madness_cure_ingredient1 = findCureIngredient()
            GLOBAL.TheWorld.state.madness_cure_ingredient2 = findCureIngredient()
            GLOBAL.TheWorld.state.madness_cure_ingredient3 = findCureIngredient()

            GLOBAL.TheWorld.state.madness_cure_cureshape = math.random(1,4)
            GLOBAL.TheWorld.state.madness_cure_curecolor1 = GetRandomMinMax(TUNING.TIDDLEMEDS_MINCOLOR, 1)
            GLOBAL.TheWorld.state.madness_cure_curecolor2 = GetRandomMinMax(TUNING.TIDDLEMEDS_MINCOLOR, 1)
            GLOBAL.TheWorld.state.madness_cure_curecolor3 = GetRandomMinMax(TUNING.TIDDLEMEDS_MINCOLOR, 1)
        end

        -- Capture Season change
        GLOBAL.TheWorld:ListenForEvent("madness_seasonchanged", OnSeasonChange)
    end
end)
