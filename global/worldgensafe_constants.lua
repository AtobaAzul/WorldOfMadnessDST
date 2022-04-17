-- Imports
local pcall = GLOBAL.pcall
local Asset = GLOBAL.Asset
local TUNING = GLOBAL.TUNING
local KnownModIndex = GLOBAL.KnownModIndex

-- Prefabs and Assets
PrefabFiles = {}
Assets = {
    Asset("SOUNDPACKAGE", "sound/madness_sounds.fev"),
    Asset("SOUND", "sound/madness_sounds_bank.fsb"),
}

-- RPC Name for Networking
MADNESS_RPC_NAME = "WorldOfMadnessRPC"

-- Recipe Unavailable Build Tag String
RECIPE_UNAVAILABLE = "recipeunavailable"

-- Global Variable to store stuff
TUNING.MADNESS = {}

-- Are We in World Gen Phase
function IsWorldGenPhase()
    local function _worldGenTestFn()
        return GLOBAL.WorldSim
    end

    -- If WorldSim exists, we're in world gen
    return pcall(_worldGenTestFn)
end

-- Mod Check
function MadnessIsModEnabled(workshop_id)
    return KnownModIndex:IsModEnabledAny(workshop_id)
end

-- Global Positions Check
function IsGlobalPositionsEnabled()
    return MadnessIsModEnabled("workshop-378160973")
end

-- The Combat Overhaul Mod Check
function IsCombatOverhaulModEnabled()
    return MadnessIsModEnabled("workshop-2317339651")
end

-- The Forge Item Pack Mod Check
function IsForgeItemPackModEnabled()
    return MadnessIsModEnabled("workshop-1221281706")
end

-- New Boat Shapes Check
function IsNewBoatShapesModEnabled()
    return MadnessIsModEnabled("workshop-2229630615")
end

-- Gem Core API Check
function IsGemCoreModEnabled()
    return MadnessIsModEnabled("workshop-1378549454")
end

-- Feast and Famine Check
function IsFeastAndFamineModEnabled()
    return MadnessIsModEnabled("workshop-1908933602")
end

-- The Black Death Mod Check
function IsBlackDeathModEnabled()
    return MadnessIsModEnabled("workshop-1982562290")
end

-- Uncompromising Mode Check
function IsUncompromisingModeEnabled()
    return MadnessIsModEnabled("workshop-2039181790")
end

-- Get whether Shard is Master
-- When there is only one shard, IsMaster() returns true so this is needed
function IsMasterShard()
    return not GLOBAL.TheShard:IsSecondary()
end

-- Copy of string.starts
function string.starts(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

-- Load String into Table
function TableLoadFromString(string)
    local t = {}

    for section in string.gmatch(string, ",*%s*([^=]+=%s*{[^{]+})") do
        local sectionName = string.match(section, "^([^%s]+)")
        t[sectionName] = {}

        for line in string.gmatch(section, "(\"[^\"]+\"%s*=[^,}]+)") do
            t[sectionName][string.match(line, "^\"([^\"]+)\"")] = string.match(line, "^\"[^\"]+\".*\"(.*)\"")
        end
    end

    return t
end

-- Generic Find in Table
function TableContains(inputTable, item)
    for k, val in pairs(inputTable) do
        if val == item then
            return true
        end
    end

    return false
end

function TableContainsWildcard(patternTable, item)
    for k, val in pairs(patternTable) do
        if item:match(val) then
            return true
        end
    end

    return false
end

-- Remove From Table
function TableRemove(inputTable, item)
    local t = {}

    for k, val in pairs(inputTable) do
        if val ~= item then
            table.insert(t, val)
        end
    end

    return t
end

-- Get Random Item From Table
function TableGetRandom(inputTable)
    if inputTable ~= nil and #inputTable > 0 then
        return inputTable[math.random(#inputTable)]
    end

    return nil
end

-- Shadow Creatures List
SHADOW_CREATURES = 
{
    "crawlinghorror",
    "terrorbeak",
    "oceanhorror",
    "creepingfear",
    "dreadeye"
}

function IsShadowCreature(prefab)
    return TableContains(SHADOW_CREATURES, prefab)
end

-- Monster Food List
MONSTER_FOODS = 
{
    "monstermeat",
    "cookedmonstermeat",
    "monstermeat_dried",
    "monsterlasagna",
    "monstersmallmeat",
    "monstersmallmeat_dried",
    "cookedmonstersmallmeat",
    "monsteregg"
}

function IsMonsterFood(prefab)
    return TableContains(MONSTER_FOODS, prefab)
end
