-- Imports
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS
modimport("features/madness_world_resets/doomsday.lua")
modimport("features/madness_world_resets/atrium_overrides.lua")
modimport("features/madness_world_resets/world_reset_disabler.lua")

-- Initial Settings
TUNING.MADNESS.world_reset_ghost_count = nil
TUNING.MADNESS.world_reset_dialog_shown = false
TUNING.MADNESS.world_reset_glommer_extra_days = 0

-- Strings
STRINGS.UI.WORLDRESETDIALOG.TITLE_LATEJOIN = "Day %d: The day the world ended...?"
