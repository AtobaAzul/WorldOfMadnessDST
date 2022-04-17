-- Imports
modimport("features/uncompromising_trapdoor_rebalance/constants.lua")

AddPrefabPostInit(
  "trapdoor",
  function(inst)
    if not GLOBAL.TheWorld.ismastersim or inst == nil then
      return
    end

    if inst.components.childspawner ~= nil and inst.components.childspawner.childspawner ~= nil and inst.components.childspawner.childspawner == "spider_trapdoor" then
        -- Remove existing spider, if any
        inst.components.childspawner:SetMaxChildren(0)
        inst.components.childspawner:StopRegen()

        -- Spawn a spider in the trapdoor
        if math.random() < UNCOMPROMISING_TRAPDOOR_SPIDER_CHANCE then
            inst.components.childspawner:SetMaxChildren(1)
            inst.components.childspawner:StartRegen()
        end
    end
end)
