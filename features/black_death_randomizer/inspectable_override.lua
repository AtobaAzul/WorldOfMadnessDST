-- Imports
local unpack = GLOBAL.unpack
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
local GetString = GLOBAL.GetString
local WET_TEXT_COLOUR = GLOBAL.WET_TEXT_COLOUR
local NORMAL_TEXT_COLOUR = GLOBAL.NORMAL_TEXT_COLOUR
local CanEntitySeeTarget = GLOBAL.CanEntitySeeTarget
local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")

-- Remove Adjectives if not clearly plagued
-- Defeats the purpose of the detector
STRINGS.DIRTYCREATURE = nil
STRINGS.SICKLYCREATURE = nil
TUNING.TIDDLESICK_TEXT_COLOUR = NORMAL_TEXT_COLOUR
TUNING.TIDDLESICK_WET_TEXT_COLOUR = WET_TEXT_COLOUR
AddClassPostConstruct("widgets/hoverer", function(self)
    local originalOnUpdate = self.OnUpdate
    function self:OnUpdate()
        originalOnUpdate(self)
        local lmb = nil
        if self.owner and self.owner.components and self.owner.components.playercontroller then
            lmb = self.owner.components.playercontroller:GetLeftMouseAction()
        end

        if lmb ~= nil and lmb.target ~= nil and lmb.target:HasTag("player") and lmb.target.playercolour ~= nil then
            self.text:SetColour(unpack(lmb.target.playercolour))
        end
    end
end)

AddPrefabPostInitAny(function(inst)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    -- Remove Sickly Description - Only show Blighted strings
    if inst.components.inspectable ~= nil then
        local OldGetDescription = UpvalueHacker.GetUpvalue(inst.components.inspectable.GetDescription, "_OldGetDescription")
        function inst.components.inspectable:GetDescription(viewer)
            if self.inst == viewer or OldGetDescription == nil then
                return
            elseif not CanEntitySeeTarget(viewer, self.inst) then
                return GetString(viewer, "DESCRIBE_TOODARK")
            end

            return (self.inst:HasTag("TiddleCurable") and not self.inst:HasTag("player") and GetString(viewer, "DESCRIBE_TIDDLEBLIGHTED"))
            or OldGetDescription(self, viewer)
        end
    end
end)
