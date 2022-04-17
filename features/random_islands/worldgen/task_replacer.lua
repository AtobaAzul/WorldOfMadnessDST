-- Imports
local ArrayUnion = GLOBAL.ArrayUnion
local tasks = GLOBAL.require("map/tasks")
modimport("features/random_islands/worldgen/constants.lua")

if math.random() < RANDOM_ISLANDS_WORLDGEN_CHANCE then

    AddLevelPreInitAny(function(tasksetdata)
        if tasksetdata.location == "forest" then
            for i, name in ipairs(ArrayUnion(tasksetdata.tasks, tasksetdata.optionaltasks)) do

                local task = tasks.GetTaskByName(name)
                if task ~= nil and (task.region_id == nil or not task.region_id:match("island")) then
                    --	Regions
                    if TableContains(RANDOM_ISLANDS_MAINLAND, name) or (math.random() < RANDOM_ISLANDS_MAINLAND_CHANCE) then
                        task.region_id = "mainland"
                    else
                        task.region_id = "madness_island_" .. math.random(1, RANDOM_ISLANDS_MAX_ISLANDS)
                        task.room_tags = ArrayUnion(task.room_tags, {"not_mainland"})
                    end
        
                    --	Size
                    local size = math.random(0, RANDOM_ISLANDS_MAX_SIZE)
                    local bgroom = task.background_room
                    if size > 0 and bgroom ~= nil then
                        task.room_choices[bgroom] = size
                    end
                end
                
            end
        end
    end)

end
