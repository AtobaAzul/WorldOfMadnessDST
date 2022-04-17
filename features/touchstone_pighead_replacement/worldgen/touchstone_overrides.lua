-- Imports
local Layouts = GLOBAL.require("map/layouts").Layouts

local function replacePigheads(layout, prefab, groundType)
    if Layouts[layout] == nil or Layouts[layout].layout["pighead"] == nil then
        return
    end

    local pigheadArray = Layouts[layout].layout["pighead"]

    -- Insert a prefab in the place of the pighead
    Layouts[layout].layout[prefab] = {}
    for k, pigheadObject in ipairs(pigheadArray) do
        table.insert(Layouts[layout].layout[prefab], {x=pigheadObject.x, y=pigheadObject.y, properties=pigheadObject.properties, width=0, height=0})
    end

    -- Remove the pigheads
    Layouts[layout].layout["pighead"] = {}

    -- Change the ground data
    for i, groundData in ipairs(Layouts[layout].ground) do
        for k, groundTile in ipairs(groundData) do

            -- 9 is the default woodboard tile
            if groundTile == 9 then
                Layouts[layout].ground[i][k] = groundType
            end

        end
    end
end

replacePigheads("ResurrectionStone", "sanityrock", 21)
replacePigheads("ResurrectionStoneLit", "sanityrock", 21)
replacePigheads("ResurrectionStoneWinter", "sanityrock", 21)
