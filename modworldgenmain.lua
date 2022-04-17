-- Global Constants
modimport("global/worldgensafe_constants.lua")

if IsWorldGenPhase() then

    -- Feautres List
    if GetModConfigData("TouchstonePigheadReplacement") == true then
        modimport("features/touchstone_pighead_replacement/worldgen/init.lua")
    end

    if GetModConfigData("RandomIslands") == true then
        modimport("features/random_islands/worldgen/init.lua")
    end

    if IsFeastAndFamineModEnabled() and GetModConfigData("FAFReduceWheat") == true then
        modimport("features/faf_reduce_wheat/worldgen/init.lua")
    end
    
    if IsUncompromisingModeEnabled() and GetModConfigData("UncompromisingSpiderRebalance") ~= "DISABLED" then
        modimport("features/uncompromising_trapdoor_rebalance/worldgen/init.lua")
    end

    -- Bug Fixes
    if GetModConfigData("ApplyBugFixes") == true then

        if IsBlackDeathModEnabled() and IsUncompromisingModeEnabled() then
            -- Fixes a crash caused by Uncompromising Mode's worldgen
            modimport("bugfixes/worldgen/black_death_uncompromising_tiddlelab.lua")
        end

    end
    
end
