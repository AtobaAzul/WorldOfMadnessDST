-- Make a copy of the tiddle_medicine prefab to create different cure types
local medPrefab = Prefabs.tiddle_medicine

if medPrefab ~= nil then
    return Prefab("madness_realcure", medPrefab.fn, medPrefab.assets),
    Prefab("madness_goodcure", medPrefab.fn, medPrefab.assets),
    Prefab("madness_badcure", medPrefab.fn, medPrefab.assets)
end
