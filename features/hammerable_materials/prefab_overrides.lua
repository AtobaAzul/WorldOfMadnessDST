-- Imports
local ACTIONS = GLOBAL.ACTIONS
local LaunchAt = GLOBAL.LaunchAt
local AllRecipes = GLOBAL.AllRecipes
local SpawnPrefab = GLOBAL.SpawnPrefab

local function onhammered(inst, worker)
    if inst ~= nil then
        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst:Remove()
    end
end

local function onhit(inst, worker)
    if inst ~= nil then

        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
        local recipe = AllRecipes[inst.prefab]

        if recipe ~= nil and not recipe.no_deconstruction then
            for k, ingredient in pairs(GetRecipeIngredients(recipe)) do
                for n = 1, math.ceil(ingredient.amount / 2) do
                    LaunchAt(SpawnPrefab(GetIngredientPrefab(ingredient)), inst, nil, 1, 1)
                end
            end
        end

        if inst.components.stackable ~= nil and inst.components.stackable:StackSize() > 1 then
            inst.components.stackable:Get():Remove()
        end

    end
end

local function OnStackChange(inst, data)
    if inst ~= nil and inst.components.workable ~= nil and data ~= nil and data.stacksize ~= nil then
        inst.components.workable:SetWorkLeft(data.stacksize)
    end
end

local function MakeHammerable(prefab)
    AddPrefabPostInit(prefab, function(inst)
        if not GLOBAL.TheWorld.ismastersim or inst == nil then
            return
        end

        local work = 1
        if inst.components.stackable ~= nil then
            work = inst.components.stackable:StackSize()
            inst:ListenForEvent("stacksizechange", OnStackChange)
        end

        if inst.components.workable == nil then
            inst:AddComponent("workable")
        end
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(work)
        inst.components.workable:SetOnWorkCallback(onhit)
        inst.components.workable:SetOnFinishCallback(onhammered)
    end)
end

MakeHammerable("rope")
MakeHammerable("boards")
MakeHammerable("cutstone")
MakeHammerable("papyrus")
