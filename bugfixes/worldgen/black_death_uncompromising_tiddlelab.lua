-- There is a crash with Uncompromising Mode worldgen's removal of the "Forest hunters" task

AddTaskSetPreInitAny(function(tasksetdata)
    if tasksetdata.set_pieces["tiddlelab"] ~= nil then
        tasksetdata.set_pieces["tiddlelab"].tasks = {"For a nice walk"}
    end
end)
