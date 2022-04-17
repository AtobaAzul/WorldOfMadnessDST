-- Imports
local SuUsed = GLOBAL.SuUsed

-- Add a global function - console command to revert the penalty if applied by mistake (unintented disconnect for example)
function c_undologoutpenalty()
    local player = GLOBAL.ConsoleCommandPlayer()
    if player ~= nil and player.components.debuffable ~= nil and not player:HasTag("playerghost") then
        SuUsed("c_undologoutpenalty", true)
        
        player.components.debuffable:RemoveDebuff("buff_madnesslogoutpenalty")
    end
end

-- Register as global command accessible from console
GLOBAL.c_undologoutpenalty = c_undologoutpenalty
