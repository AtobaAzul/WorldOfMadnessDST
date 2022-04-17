-- The deadly flag isn't being saved
-- deadly_disease config option MUST be set to false
-- or this is overriden!

-- Virus Component Override
AddComponentPostInit("tiddlevirus", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end
    
    local originalOnSave = self.OnSave
    function self:OnSave()
        local data = originalOnSave(self)
        data.deadly = self.deadly
        return data
    end

    local originalOnLoad = self.OnLoad
    function self:OnLoad(data)
        originalOnLoad(self, data)
        if data.deadly ~= nil then 
            self.deadly = data.deadly
        end
    end
end)
