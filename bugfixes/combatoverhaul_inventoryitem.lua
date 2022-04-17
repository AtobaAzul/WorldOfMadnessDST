-- Combat Overhaul causes self.classified to somehow be nil and this causes a crash
AddClassPostConstruct("components/inventoryitem_replica", function(self)

    local originalSetAttackRange = self.SetAttackRange
    function self:SetAttackRange(attackrange)
        if self.classified ~= nil then
            originalSetAttackRange(self, attackrange)
        end
    end

end)
