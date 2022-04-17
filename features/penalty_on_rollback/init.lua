-- Imports
local TUNING = GLOBAL.TUNING
modimport("features/penalty_on_rollback/console_command_overrides.lua")
modimport("features/penalty_on_rollback/rollback_overrides.lua")

-- Initial Setting
TUNING.MADNESS.allow_rollback = false
