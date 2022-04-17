-- Global Constants
modimport("global/constants.lua")
modimport("global/worldgensafe_constants.lua")

-- Feautres List
if GetModConfigData("DebugMode") == true then
    modimport("features/debug_mode/init.lua")
end

if GetModConfigData("DiscordLogging") ~= "DISABLED" then
    modimport("features/discord_logging/init.lua")
end

if GetModConfigData("MoreAdminCommands") == true then
    modimport("features/more_admin_commands/init.lua")
end

if GetModConfigData("WortoxRebalance") == true then
    modimport("features/wortox_rebalance/init.lua")
end

if GetModConfigData("CappedHungerFoods") == true then
    modimport("features/capped_hunger_foods/init.lua")
end

if GetModConfigData("GlobalDamage") == true then
    modimport("features/global_combat_damage/init.lua")
end

if GetModConfigData("LessNightmareFuel") == true then
    modimport("features/less_nightmare_fuel/init.lua")
end

if GetModConfigData("ArmorDegradation") == true then
    modimport("features/armor_degradation/init.lua")
end

if GetModConfigData("WeaponDegradation") == true then
    modimport("features/weapon_degradation/init.lua")
end

if GetModConfigData("DropItemsOnLogout") == true then
    modimport("features/drop_items_on_logout/init.lua")
end

if GetModConfigData("PenaltyOnLogout") == true then
    modimport("features/penalty_on_logout/init.lua")
end

if GetModConfigData("PenaltyOnRollback") == true then
    modimport("features/penalty_on_rollback/init.lua")
end

if GetModConfigData("DisableGhostDrain") == true then
    modimport("features/disable_ghost_sanity_drain/init.lua")
end

if GetModConfigData("TorchOnResurrect") == true then
    modimport("features/torch_on_resurrect/init.lua")
end

if GetModConfigData("LongerHarshSeasons") == true then
    modimport("features/longer_harsh_seasons/init.lua")
end

if GetModConfigData("RandomSeasonLengths") == true then
    modimport("features/random_season_lengths/init.lua")
end

if GetModConfigData("HammerableMaterials") == true then
    modimport("features/hammerable_materials/init.lua")
end

if GetModConfigData("MadnessWorldResets") == true then
    modimport("features/madness_world_resets/init.lua")
end

if IsNewBoatShapesModEnabled() and GetModConfigData("NewBoatShapesIncreaseCost") == true then
    modimport("features/newboatshapes_increase_cost/init.lua")
end

if IsBlackDeathModEnabled() and GetModConfigData("BlackDeathDeadlyRandomize") == true then
    modimport("features/black_death_randomizer/init.lua")
end

if IsBlackDeathModEnabled() and GetModConfigData("BlackDeathDisableCharacter") == true then
    modimport("features/black_death_character_disabler/init.lua")
end

if IsUncompromisingModeEnabled() and GetModConfigData("UncompromisingSpiderRebalance") ~= "DISABLED" then
    modimport("features/uncompromising_trapdoor_rebalance/init.lua")
end

-- Bug Fixes
if GetModConfigData("ApplyBugFixes") == true then
    
    -- Fixes ghosts not being able to float over cliffs in caves
    modimport("bugfixes/ghosts_float_in_caves.lua")

    -- The deadly flag isn't persisted by default
    if IsBlackDeathModEnabled() then
        modimport("bugfixes/black_death_save_deadly_flag.lua")
    end

end
