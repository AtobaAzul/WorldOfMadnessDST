-- Imports
modimport("features/uncompromising_trapdoor_rebalance/constants.lua")

local function AdjustTrapdoorSpawner(room)
    if room ~= nil and room.contents.countprefabs ~= nil and room.contents.countprefabs['trapdoorspawner'] ~= nil then
        room.contents.countprefabs['trapdoorspawner'] = UNCOMPROMISING_TRAPDOOR_SPAWN_COUNT
    end
end

AddRoomPreInit("BGSavanna", function(room)
    AdjustTrapdoorSpawner(room)
end)

AddRoomPreInit("Plain", function(room)
    AdjustTrapdoorSpawner(room)
end)
