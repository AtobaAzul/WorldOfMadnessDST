-- Imports
local AllRecipes = GLOBAL.AllRecipes
local RECIPETABS = GLOBAL.RECIPETABS
local CUSTOM_RECIPETABS = GLOBAL.CUSTOM_RECIPETABS

-- Remove Forge Tab
CUSTOM_RECIPETABS["The Forge"] = nil

-- Set a builder tag to make the recipe unavailable
-- Not needed if combat overhaul mod is there
if IsCombatOverhaulModEnabled() and AllRecipes["riledlucy"] ~= nil then
    AllRecipes["riledlucy"].builder_tag = RECIPE_UNAVAILABLE
end

-- WAR --
if AllRecipes["forgedarts"] ~= nil then
    AllRecipes["forgedarts"].tab = RECIPETABS.WAR
    AllRecipes["forgedarts"].sortkey = GetRecipeSortKey("blowdart_yellow") + .1
end

if AllRecipes["moltendarts"] ~= nil then
    AllRecipes["moltendarts"].tab = RECIPETABS.WAR
    AllRecipes["moltendarts"].sortkey = GetRecipeSortKey("blowdart_yellow") + .2
end

if AllRecipes["pithpike"] ~= nil then
    AllRecipes["pithpike"].tab = RECIPETABS.WAR
    AllRecipes["pithpike"].sortkey = GetRecipeSortKey("spear") + .1
end

if AllRecipes["spiralspear"] ~= nil then
    AllRecipes["spiralspear"].tab = RECIPETABS.WAR
    AllRecipes["spiralspear"].sortkey = GetRecipeSortKey("spear") + .2
end

if AllRecipes["blacksmith_edge"] ~= nil then
    AllRecipes["blacksmith_edge"].tab = RECIPETABS.WAR
    AllRecipes["blacksmith_edge"].sortkey = GetRecipeSortKey("spear") + .3
end

if AllRecipes["reedtunic"] ~= nil then
    AllRecipes["reedtunic"].tab = RECIPETABS.WAR
    AllRecipes["reedtunic"].sortkey = GetRecipeSortKey("armormarble") + .1
end

if AllRecipes["featheredtunic"] ~= nil then
    AllRecipes["featheredtunic"].tab = RECIPETABS.WAR
    AllRecipes["featheredtunic"].sortkey = GetRecipeSortKey("armormarble") + .2
end

if AllRecipes["forge_woodarmor"] ~= nil then
    AllRecipes["forge_woodarmor"].tab = RECIPETABS.WAR
    AllRecipes["forge_woodarmor"].sortkey = GetRecipeSortKey("armormarble") + .3
end

if AllRecipes["jaggedarmor"] ~= nil then
    AllRecipes["jaggedarmor"].tab = RECIPETABS.WAR
    AllRecipes["jaggedarmor"].sortkey = GetRecipeSortKey("armormarble") + .4
end

if AllRecipes["silkenarmor"] ~= nil then
    AllRecipes["silkenarmor"].tab = RECIPETABS.WAR
    AllRecipes["silkenarmor"].sortkey = GetRecipeSortKey("armormarble") + .5
end

if AllRecipes["splintmail"] ~= nil then
    AllRecipes["splintmail"].tab = RECIPETABS.WAR
    AllRecipes["splintmail"].sortkey = GetRecipeSortKey("armormarble") + .6
end

if AllRecipes["steadfastarmor"] ~= nil then
    AllRecipes["steadfastarmor"].tab = RECIPETABS.WAR
    AllRecipes["steadfastarmor"].sortkey = GetRecipeSortKey("armormarble") + .7
end

if AllRecipes["armor_hpextraheavy"] ~= nil then
    AllRecipes["armor_hpextraheavy"].tab = RECIPETABS.WAR
    AllRecipes["armor_hpextraheavy"].sortkey = GetRecipeSortKey("armormarble") + .8
end

if AllRecipes["armor_hpdamager"] ~= nil then
    AllRecipes["armor_hpdamager"].tab = RECIPETABS.WAR
    AllRecipes["armor_hpdamager"].sortkey = GetRecipeSortKey("armormarble") + .9
end

if AllRecipes["armor_hprecharger"] ~= nil then
    AllRecipes["armor_hprecharger"].tab = RECIPETABS.WAR
    AllRecipes["armor_hprecharger"].sortkey = GetRecipeSortKey("armormarble") + .10
end

if AllRecipes["armor_hppetmastery"] ~= nil then
    AllRecipes["armor_hppetmastery"].tab = RECIPETABS.WAR
    AllRecipes["armor_hppetmastery"].sortkey = GetRecipeSortKey("armormarble") + .11
end

if AllRecipes["barbedhelm"] ~= nil then
    AllRecipes["barbedhelm"].tab = RECIPETABS.WAR
    AllRecipes["barbedhelm"].sortkey = GetRecipeSortKey("footballhat") + .1
end

if AllRecipes["noxhelm"] ~= nil then
    AllRecipes["noxhelm"].tab = RECIPETABS.WAR
    AllRecipes["noxhelm"].sortkey = GetRecipeSortKey("footballhat") + .2
end

if AllRecipes["resplendentnoxhelm"] ~= nil then
    AllRecipes["resplendentnoxhelm"].tab = RECIPETABS.WAR
    AllRecipes["resplendentnoxhelm"].sortkey = GetRecipeSortKey("footballhat") + .3
end


-- DRESS --
if AllRecipes["featheredwreath"] ~= nil then
    AllRecipes["featheredwreath"].tab = RECIPETABS.DRESS
    AllRecipes["featheredwreath"].sortkey = GetRecipeSortKey("flowerhat") + .1
end

if AllRecipes["crystaltiara"] ~= nil then
    AllRecipes["crystaltiara"].tab = RECIPETABS.DRESS
    AllRecipes["crystaltiara"].sortkey = GetRecipeSortKey("flowerhat") + .2
end

if AllRecipes["flowerheadband"] ~= nil then
    AllRecipes["flowerheadband"].tab = RECIPETABS.DRESS
    AllRecipes["flowerheadband"].sortkey = GetRecipeSortKey("flowerhat") + .3
end

if AllRecipes["wovengarland"] ~= nil then
    AllRecipes["wovengarland"].tab = RECIPETABS.DRESS
    AllRecipes["wovengarland"].sortkey = GetRecipeSortKey("flowerhat") + .4
end

if AllRecipes["clairvoyantcrown"] ~= nil then
    AllRecipes["clairvoyantcrown"].tab = RECIPETABS.DRESS
    AllRecipes["clairvoyantcrown"].sortkey = GetRecipeSortKey("flowerhat") + .5
end

if AllRecipes["blossomedwreath"] ~= nil then
    AllRecipes["blossomedwreath"].tab = RECIPETABS.DRESS
    AllRecipes["blossomedwreath"].sortkey = GetRecipeSortKey("flowerhat") + .6
end


-- TOOLS --
if AllRecipes["forginghammer"] ~= nil then
    AllRecipes["forginghammer"].tab = RECIPETABS.TOOLS
    AllRecipes["forginghammer"].sortkey = GetRecipeSortKey("hammer") + .1
end


-- MAGIC --
if AllRecipes["livingstaff"] ~= nil then
    AllRecipes["livingstaff"].tab = RECIPETABS.MAGIC
    AllRecipes["livingstaff"].sortkey = GetRecipeSortKey("telestaff") + .1
end

if AllRecipes["infernalstaff"] ~= nil then
    AllRecipes["infernalstaff"].tab = RECIPETABS.MAGIC
    AllRecipes["infernalstaff"].sortkey = GetRecipeSortKey("telestaff") + .2
end

if AllRecipes["petrifyingtome"] ~= nil then
    AllRecipes["petrifyingtome"].tab = RECIPETABS.MAGIC
    AllRecipes["petrifyingtome"].sortkey = GetRecipeSortKey("telestaff") + .3
end

if AllRecipes["bacontome"] ~= nil then
    AllRecipes["bacontome"].tab = RECIPETABS.MAGIC
    AllRecipes["bacontome"].sortkey = GetRecipeSortKey("telestaff") + .4
end

if AllRecipes["hearthsfire_crystals"] ~= nil then
    AllRecipes["hearthsfire_crystals"].tab = RECIPETABS.MAGIC
    AllRecipes["hearthsfire_crystals"].sortkey = GetRecipeSortKey("telestaff") + .5
end
