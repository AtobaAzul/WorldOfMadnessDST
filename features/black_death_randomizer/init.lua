-- CREDITS
-- A HUGE thank you to the Black Death mod dev team, and in particular The Tiddler.
-- This mod brings changes with his blessing.
-- World of Madness simply changes a few mechanics but credit goes entirely to the Black Death mod dev team.

-- Imports
modimport("features/black_death_randomizer/cures_override.lua")
modimport("features/black_death_randomizer/hounds_override.lua")
modimport("features/black_death_randomizer/inspectable_override.lua")
modimport("features/black_death_randomizer/tiddlecannon_override.lua")
modimport("features/black_death_randomizer/virus_component_override.lua")
modimport("features/black_death_randomizer/console_command_overrides.lua")

-- Prefabs
table.insert(PrefabFiles, "madness_black_death_meds")
