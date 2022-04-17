-- Reduce Wheat Generation
AddRoomPreInit("BGSavanna", function(room) room.contents.distributeprefabs.wheatgrass = 0.01 end)
AddRoomPreInit("Plain", function(room) room.contents.distributeprefabs.wheatgrass = 0.01 end)
AddRoomPreInit("BeefalowPlain", function(room) room.contents.distributeprefabs.wheatgrass = 0.01 end)
AddRoomPreInit("BGGrass", function(room) room.contents.countprefabs.wheatgrass = 0.1 * math.random(1) end)
AddRoomPreInit("BarePlain", function(room) room.contents.distributeprefabs.wheatgrass = 0.1 * math.random(3) end)
