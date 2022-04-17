------------------------------
-- Mod Info
------------------------------
name = "󰀕 World of Madness"
author = "Lecernawx, Atobá Azul "
version = "3.16.8"

description = [[󰀏 Version ]] .. version .. [[

Small server adjustments making the game more... interesting.

󰀘 Prominent features:
- Global damage is re-balanced and degrades with hunger/sanity
- Weapon and Armor efficiency degenerate as they get damaged
- Birdcages can no longer be abused
- Nightmare fuel is harder to find
- Force items to drop on disconnect
- Rebalance to the Wortox character
  Wortox now relies on souls for hunger but at the cost of his sanity

󰀈 This mod is compatible with the "Uncompromising Mod" for an even harder challenge.
- Trapdoor spiders have had their spawn chance adjusted
- Compatible with the Stalking Stuffers update]]

------------------------------
-- Prettifying Functions
-- Credit to the Uncompromising Mod
------------------------------
local function Header(title)
	return { name = "", label = title, hover = "", options = { {description = "", data = false}, }, default = false, }
end

local function SkipSpace()
	return { name = "", label = "", hover = "", options = { {description = "", data = false}, }, default = false, }
end

local function BinaryConfig(name, label, hover, default)
    return { name = name, label = label, hover = hover, options = { {description = "Enabled", data = true}, {description = "Disabled", data = false}, }, default = default, }
end

------------------------------
-- Mod Flags
------------------------------
client_only_mod = false
server_only_mod = false
all_clients_require_mod = true
dst_compatible = true
restart_require = false
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"

-- Priority one lower than the mod default of 0 to override conflicting functions (everything else loads first, this loads last).
-- Must go even lower due to Combat Overhaul's priority of -1505270912
priority = -1777777777

server_filter_tags = {
  "challenge",
  "survivor",
  "survivors",
  "club"
}

------------------------------
-- Configuration Options
------------------------------
configuration_options =
{
------------------------------
-- General Features --
------------------------------
Header("General Features"),
  BinaryConfig("GlobalDamage", "Global Combat Damage", "Global combat damage is adjusted. Also, lower hunger/sanity means you get hit harder and your hits are weaker.", true),
  BinaryConfig("WeaponDegradation", "Weapon Degradation", "When enabled, weapons degrade in efficiency as they get damaged.", true),
  BinaryConfig("ArmorDegradation", "Armor Degradation", "When enabled, armor degrades in efficiency as it gets damaged.", true),
  BinaryConfig("BirdcageRebalance", "Birdcage Adjustments", "When enabled, birdcages can no longer be abused using monster meat.", true),
  BinaryConfig("WeakerVeggies", "Less Nutritious Vegetables", "When enabled, uncooked vegetables restore less hunger to incentivize cooking meals. Credit to Atoba Lunar.", true),
  BinaryConfig("CappedHungerFoods", "Maximum Food Calories", "When enabled, sets a calorie cap to foods. This is mainly used to nerf overpowered crockpot foods.", true),
  BinaryConfig("LessNightmareFuel", "Less Nightmare Fuel Drops", "When enabled, Nightmare Fuel no longer drops from Shadow Creatures unless Maxwell is near.", true),
  BinaryConfig("TouchstonePigheadReplacement", "Replace Touch Stone Pig Heads", "When enabled, replaces the Pig Heads found near Touch Stones with Obelisks.", true),
  BinaryConfig("HarshSeasonHelp", "Harsh Season Aid", "When enabled, the game will provide some help to players joining during harsh seasons.", true),
  BinaryConfig("MoondialWaterSource", "Water from Moon Dials", "When enabled, the Moon Dial can be used to refill watering cans.", true),
  BinaryConfig("HammerableMaterials", "Hammerable Basic Materials", "When enabled, allow ropes, boards and cut stones to be hammered for materials.", true),
  BinaryConfig("RandomIslands", "Generate Islands", "When enabled, world gen will sometimes split the world into islands.", true),
  BinaryConfig("WortoxRebalance", "Wortox Adjustments", "Wortox requires souls to survive, and gets a sanity aura debuff, among other character rebalances.", true),

------------------------------
-- The Combat Overhaul --
------------------------------
Header("The Combat Overhaul"),
BinaryConfig("CombatOverhaulReduceAttackSpeed", "Rebalance Combat", "Reduces attack speed and balances things to make weapons less overpowered. Disabling the feature will result in the Combat Overhaul Mod default.", true),

------------------------------
-- The Forge Item Pack --
------------------------------
Header("The Forge Item Pack"),
BinaryConfig("ForgeItemPackRecategorize", "Recategorize Item Tabs", "Moves some weapons to tabs where they make more sense. Disabling the feature will result in the Forge Item Pack Mod default.", true),

------------------------------
-- New Boat Shapes --
------------------------------
Header("New Boat Shapes"),
BinaryConfig("NewBoatShapesRemoveDefaultBoat", "Remove Default Boat", "Removes the default boat craft. Disabling the feature will result in the New Boat Shapes Mod default.", true),
BinaryConfig("NewBoatShapesIncreaseCost", "Increase Custom Boat Cost", "Increase the cost of building custom boats. Disabling the feature will result in the New Boat Shapes Mod default.", true),

------------------------------
-- Feast and Famine --
------------------------------
Header("Feast and Famine"),
BinaryConfig("FAFReduceWheat", "Reduce Wheat Spawns", "Reduces the amount of wheat that spawns in the world. Disabling the feature will result in the Feast and Famine Mod default.", true),

------------------------------
-- The Black Death --
------------------------------
Header("The Black Death"),
  BinaryConfig("BlackDeathDeadlyRandomize", "Rebalance Black Death", "General re-balance of the Black Death mod. Deadly Disease flag in the Black Death Mod must be set to Disabled.", true),
  BinaryConfig("BlackDeathDisableCharacter", "Disable Custom Characters", "Disables custom characters while preserving mod functionality. Disabling the feature will result in the Black Death Mod default.", true),

------------------------------
-- Uncompromising Mode --
------------------------------
Header("Uncompromising Mode"),
  BinaryConfig("UncompromisingInkSplats", "Restore Shadow Ink Splats", "Restore Shadow Creatures shooting ink splats to players in range. Disabling the feature will result in the Uncompromising Mode default.", true),
  {
    name = "UncompromisingSpiderRebalance",
    label = "Trapdoor Spider Reduction",
    hover = "Reduces the chance of encountering a trapdoor spider in Uncompromising Mode. Disabling the feature will result in the Uncompromising Mode default.",
    options =	{
      {description = "No Spiders", data = "NONE"},
      {description = "Few Spiders", data = "FEW"},
      {description = "Disabled", data = "DISABLED"},
    },
    default = "FEW",
  },

------------------------------
-- Gameplay Options --
------------------------------
Header("Gameplay Options"),
  BinaryConfig("DropItemsOnLogout", "Drop Items On Logoff", "To prevent griefing and encourage new players joining existing servers, players will drop all non-starter items when logging off.", true),
  BinaryConfig("PenaltyOnLogout", "Penalty On Logoff", "Players that log off during the night, close to nightfall or during combat will recieve a penalty.", true),
  BinaryConfig("PenaltyOnRollback", "Penalty On Rollback", "Rolling back is a thing of the past. Players will recieve a penalty instead if a vote passes.", true),
  BinaryConfig("DisableGhostDrain", "Remove Ghost Sanity Drain", "Removes the global sanity drain caused by ghosts. They still drain sanity when close to players however.", true),
  BinaryConfig("TorchOnResurrect", "Torch On Resurrect", "Players who resurrect in caves or in the dark respawn with a torch.", true),
  BinaryConfig("LongerHarshSeasons", "Harsher Season Lengths", "Changes the duration of harsh seasons to make them longer than friendly ones.", true),
  BinaryConfig("RandomSeasonLengths", "Random Season Lengths", "Randomizes the length of seasons every year, while keeping the length of a year consistent.", true),
  BinaryConfig("MadnessWorldResets", "Madness Survival Mode", "The world reset timer is stopped by socketing a Cratered Moonrock in the Ancient Gateway. Not doing so can have dire consequences...", true),
  BinaryConfig("ApplyBugFixes", "Apply Bug Fixes", "Applies various bug fixes to the base game and to some mods.", true),

------------------------------
-- Discord Logging --
------------------------------
Header("Discord Logging"),
{
  name = "DiscordLogging",
  label = "Send Events to Discord",
  hover = "Enchances logging to send information to Discord. The value of this setting must be set manually in modoverrides as the Discord webhook URL.",
  options =	{
    {description = "Disabled", data = "DISABLED"}
  },
  default = "DISABLED",
},
{
  name = "DiscordLoggingEmojis",
  label = "Emoji ID List for Discord",
  hover = "List of Emoji IDs to use when communicating with Discord. The value of this setting must be set manually in modoverrides.",
  options =	{
    {description = "Disabled", data = "DISABLED"}
  },
  default = "DISABLED",
},

------------------------------
-- Development --
------------------------------
Header("Development"),
  BinaryConfig("MoreAdminCommands", "More Console Commands", "Enables more console admin commands.", true),
  BinaryConfig("DebugMode", "Debug Mode", "Enable or disable game cheats via the console.", false)
------------------------------
}
