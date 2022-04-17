-- Imports
modimport("features/black_death_randomizer/constants.lua")

-- Virus Component Override
AddComponentPostInit("tiddlevirus", function(self)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim then
        return
    end

    -- Adds flag to detect newly spawned entities
    self.madness_fresh_spawn_check = false

    local originalOnSave = self.OnSave
    function self:OnSave()
        local data = originalOnSave(self)
        data.madness_fresh_spawn_check = self.madness_fresh_spawn_check
        return data
    end

    local originalOnLoad = self.OnLoad
    function self:OnLoad(data)
        originalOnLoad(self, data)
        if data.madness_fresh_spawn_check ~= nil then 
            self.madness_fresh_spawn_check = data.madness_fresh_spawn_check
        end
    end
    
    local originalPushVirus = self.PushVirus
    function self:PushVirus(amount, source, instant)
        -- Check transmit rate
        if math.random() < VIRUS_TRANSMIT_RATE then

            -- Check whether this strain is deadly
            if math.random() < DEADLY_VIRUS_CHANCE then
                self.deadly = true
            else
                self.deadly = false
            end
    
            originalPushVirus(self, amount, source, instant)

        end
    end
end)

-- Creatures with immunity
for i, prefab in ipairs(VIRUS_IMMUNITY_LIST) do
    AddPrefabPostInit(prefab, function(inst)
        -- Client check
        if not GLOBAL.TheWorld.ismastersim or inst == nil then
            return
        end

        inst:AddTag("tiddlevirusimmune")
    end)
end

-- Do not allow players, starter items or player initial followers to start with the virus
AddPrefabPostInitAny(function(inst)
    -- Client check
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
        return
    end

    if inst.components.tiddlevirus ~= nil then
        inst:DoTaskInTime(1, function()
            if (inst.components.tiddlevirus.madness_fresh_spawn_check == nil or not inst.components.tiddlevirus.madness_fresh_spawn_check)
            and ((IsPlayer(inst))
            or (inst.components.follower ~= nil and inst.components.follower:GetLeader() ~= nil and IsPlayer(inst.components.follower:GetLeader()))
            or (inst.prefab ~= nil and IsStarterItem(inst.prefab))) then
                inst.components.tiddlevirus.madness_fresh_spawn_check = true
                inst.components.tiddlevirus:StopVirus()
            end
        end)
    end
end)
