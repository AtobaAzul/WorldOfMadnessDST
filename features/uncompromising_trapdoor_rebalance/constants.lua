-- Uncompromising Trapdoors
if GetModConfigData("UncompromisingSpiderRebalance") == "NONE" then
    UNCOMPROMISING_TRAPDOOR_SPIDER_CHANCE = 0
    UNCOMPROMISING_TRAPDOOR_SPAWN_COUNT = 0
else
    UNCOMPROMISING_TRAPDOOR_SPIDER_CHANCE = 0.05
    UNCOMPROMISING_TRAPDOOR_SPAWN_COUNT = math.random(2, 5)
end
