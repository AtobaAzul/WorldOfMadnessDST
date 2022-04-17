-- Imports
local ACTIONS = GLOBAL.ACTIONS
local AllRecipes = GLOBAL.AllRecipes
local SpawnPrefab = GLOBAL.SpawnPrefab
local MODCHARACTEREXCEPTIONS_DST = GLOBAL.MODCHARACTEREXCEPTIONS_DST

-- Remove mod characters
local character_name = "tiddlewade"
table.insert(MODCHARACTEREXCEPTIONS_DST, character_name)

-- Keep custom functionality
AllRecipes["tiddlesoap"].builder_tag = nil
AllRecipes["tiddlesoap"].sortkey = GetRecipeSortKey("tiddlestick") - .1

ACTIONS.TIDDLECLEAN.fn = function(act)
    local target = act.target or act.doer

	if act.invobject ~= nil and act.invobject.components.tiddlecleaner ~= nil and target.components.health ~= nil then
	    act.invobject.components.tiddlecleaner:Clean(target, act.doer)
	    return true
    end
end

AddComponentAction("USEITEM", "tiddlecleaner", function(inst, doer, target, actions, right)
	if target:HasTag("_health") then
	    table.insert(actions, ACTIONS.TIDDLECLEAN)
	end
end)

AddComponentAction("INVENTORY", "tiddlecleaner", function(inst, doer, actions, right)
    table.insert(actions, ACTIONS.TIDDLECLEAN)
end)

AddComponentPostInit("tiddlecleaner", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    function self:Clean(target, cleaner)
        if target.components.tiddlevirus ~= nil and target:HasTag("TiddleVirus") and not target:HasTag("TiddleSymptoms") then
            target.components.tiddlevirus:StopVirus()
        end

        local x, y, z = target.Transform:GetWorldPosition()
        SpawnPrefab("tiddlesoap_fx").Transform:SetPosition(x, y + 0.25, z)

        if self.inst.components.finiteuses ~= nil then
            self.inst.components.finiteuses:Use(1)
        end
    
        return true
    end
end)

local function OnNewPlayerSpawn(inst, player)
    if player.prefab == character_name then
        inst:PushEvent("ms_playerdespawnanddelete", player)
    end
end

-- World events - Server-side Check
AddSimPostInit(function()
    -- This is a server-side check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    GLOBAL.TheWorld:ListenForEvent("ms_newplayerspawned", OnNewPlayerSpawn)
end)
