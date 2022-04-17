-- Imports
local TECH = GLOBAL.TECH
local STRINGS = GLOBAL.STRINGS
local AllRecipes = GLOBAL.AllRecipes
local RECIPETABS = GLOBAL.RECIPETABS
local SpawnPrefab = GLOBAL.SpawnPrefab
local CAMERASHAKE = GLOBAL.CAMERASHAKE
local ShakeAllCameras = GLOBAL.ShakeAllCameras
local TechTree = GLOBAL.require("techtree")
local containers = GLOBAL.require("containers")
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
modimport("features/black_death_randomizer/constants.lua")

-- Change cannon to take plague extract instead of critters
-- Must back track if UM is enabled, as it overrides the containers.widgetsetup after The Black Plague does
-- This hack must happen because the containers add a readonly flag to the variable we're trying to change

STRINGS.NAMES.TIDDLECANNON = "Plague Cannon"
STRINGS.RECIPE_DESC.TIDDLECANNON = "Spread the plague, in style."

STRINGS.CHARACTERS.WOODIE.DESCRIBE.TIDDLECANNON = "Now I'm not a fan of the plague, but..."
STRINGS.CHARACTERS.WARLY.DESCRIBE.TIDDLECANNON = "An interesting use of plague extract..."
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.TIDDLECANNON = "Plague go boom!"
STRINGS.CHARACTERS.WURT.DESCRIBE.TIDDLECANNON = "Flort. Don't aim it at me!"

if AllRecipes["tiddlecannon"] ~= nil then
    AllRecipes["tiddlecannon"].tab = RECIPETABS.WAR
    AllRecipes["tiddlecannon"].level = TechTree.Create(TECH.SCIENCE_TWO)
    AllRecipes["tiddlecannon"].sortkey = GetRecipeSortKey("hambat") - .1
end

local widgetstartingpoint
if IsUncompromisingModeEnabled() then
    widgetstartingpoint = UpvalueHacker.GetUpvalue(containers.widgetsetup, "old_wsetup")
else
    widgetstartingpoint = containers.widgetsetup
end

local Oldwidgetsetup = UpvalueHacker.GetUpvalue(widgetstartingpoint, "containers_widgetsetup")
local modparams = UpvalueHacker.GetUpvalue(widgetstartingpoint, "params")
modparams.tiddlecannon.acceptsstacks = true
modparams.tiddlecannon.itemtestfn = function(container, item, slot)
    return (item.prefab ~= nil and (item.prefab == "tiddlecure" or item.prefab == "tiddlesoap"))
end

local function newWidgetSetup(container, prefab, data)
    if modparams[prefab or container.inst.prefab] and not data then
		data = modparams[prefab or container.inst.prefab]
	end
	Oldwidgetsetup(container, prefab, data)
end

if IsUncompromisingModeEnabled() then
    UpvalueHacker.SetUpvalue(containers.widgetsetup, newWidgetSetup, "old_wsetup")
else
    containers.widgetsetup = newWidgetSetup
end

-- Remove one item of the stack rather than the entire stack on shoot
AddComponentPostInit("tiddlecannon", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    function self:Shoot(target, shooter)
        if self.inst.components.container ~= nil and self.projectile ~= nil then
            local projectileItem = self.inst.components.container.slots[1]
            if projectileItem ~= nil and projectileItem.prefab ~= nil then

                local proj = SpawnPrefab(self.projectile)
                if proj ~= nil then

                    proj.damage = VIRUS_CANNON_DAMAGE
                    if projectileItem.prefab == "tiddlesoap" then
                        proj.soap = true
                    end

                    if proj.components.complexprojectile ~= nil then
                        proj.components.complexprojectile.owningweapon = self.inst
                        proj.Transform:SetPosition(shooter.Transform:GetWorldPosition())
                        proj.components.complexprojectile:Launch(target, shooter, self.inst)
                    end

                    if self.inst.sound ~= nil and proj.SoundEmitter ~= nil then
                        proj.SoundEmitter:PlaySound(self.inst.sound)
                    end
        
                    if projectileItem.components.stackable then
                        projectileItem.components.stackable:Get():Remove()
                    else
                        projectileItem:Remove()
                    end
        
                    if self.inst.components.finiteuses ~= nil then
                        self.inst.components.finiteuses:Use(1)
                    end

                end

            end
        end
    
        return true
    end
end)

AddPrefabPostInit("tiddlecannon", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    if inst.components.finiteuses ~= nil then
        inst.components.finiteuses:SetMaxUses(VIRUS_CANNON_USES)
        inst.components.finiteuses:SetUses(VIRUS_CANNON_USES)
    end
end)

AddPrefabPostInit("tiddlecannon_shot", function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    inst.soap = false

    if inst.components.complexprojectile ~= nil then
        originalonhitfn = inst.components.complexprojectile.onhitfn
        inst.components.complexprojectile.onhitfn = function(inst, attacker, target)
            if inst.soap == true then

                local effect = SpawnPrefab("tiddlesoap_fx")
                effect.Transform:SetScale(2, 2, 2)
                effect.Transform:SetPosition(inst.Transform:GetWorldPosition())

                ShakeAllCameras(CAMERASHAKE.SIDE, .1, .05, .1, inst, 40)
                local x, y, z = inst.Transform:GetWorldPosition()
                local ents = GLOBAL.TheSim:FindEntities(x, y, z, VIRUS_CANNON_SOAP_RANGE)
                for i, ent in ipairs(ents) do
                    if ent ~= nil and ent:IsValid() then

                        if ent.prefab ~= nil and ent.prefab == "tiddle_decay" then
                            SpawnPrefab("tiddlesoap_fx").Transform:SetPosition(ent.Transform:GetWorldPosition())
                            ent:Remove()
                        elseif ent.components.tiddlevirus ~= nil and ent:HasTag("TiddleVirus") and not ent:HasTag("TiddleSymptoms") then
                            SpawnPrefab("tiddlesoap_fx").Transform:SetPosition(ent.Transform:GetWorldPosition())
                            ent.components.tiddlevirus:StopVirus()
                        end

                    end
                end

                inst:DoTaskInTime(0.1, function()
                    inst:Remove()
                end)

            else
                originalonhitfn(inst, attacker, target)
            end
        end
    end
end)
