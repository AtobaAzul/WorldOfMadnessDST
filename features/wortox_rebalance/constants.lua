-- Imports
local TUNING = GLOBAL.TUNING
local STRINGS = GLOBAL.STRINGS

-- Basic starting values
TUNING.WORTOX_HEALTH = 150
TUNING.WORTOX_HUNGER = 175
TUNING.WORTOX_SANITY = 200

-- Food debuff
TUNING.WORTOX_FOOD_MULT = 0

-- Soul-related stats
TUNING.WORTOX_MAX_SOULS = 30
TUNING.WORTOX_SOULHEAL_RANGE = 20

-- Spawn soul anywhere on the map
-- Hacky way for IsNear function to detect a soul by using a unique ID for range
TUNING.WORTOX_SOULEXTRACT_RANGE = 517815651110242120002

-- Soul Heal Multiplier
SOUL_HEAL_MULTIPLIER = 0.75
SOUL_HEAL_HUNGER_DEBUFF = math.floor(TUNING.CALORIES_SMALL / 2)

-- Soul Eating Hunger Buff
SOUL_EAT_HUNGER_BUFF = TUNING.CALORIES_SMALL
SOUL_EAT_SANITY_DEBUFF = TUNING.SANITY_TINY

-- Wortox Debuff Frequencies
WORTOX_SANITY_MIN_PERCENT = 0.5
WORTOX_SANITY_MAX_TICKCOUNT = 12

WORTOX_LARGE_SANITY_DEBUFF_FREQUENCY = 1
WORTOX_LARGE_SANITY_DEBUFF_RANGE = 12
WORTOX_LARGE_SANITY_DEBUFF_GAIN = 1
WORTOX_LARGE_SANITY_DEBUFF_LOSS = 1
WORTOX_LARGE_SANITY_DEBUFF_THRESHOLD = 0.375

-- Wortox Sanity Debuff Character Immunities
WORTOX_SANITY_DEBUFF_IMMUNE_CHARACTERS = 
{
    "walter"
}

-- Soul Generation Overrides
WORTOX_RESTORE_SOULS = 
{
    "bee",
    "killerbee",
    "butterfly",
    "aphid"
}

WORTOX_REMOVE_SOULS =
{
    "stalker_minion"
}

WORTOX_REMOVE_VEGGIE_TAG =
{
    "snapdragon",
    "fruitbat"
}

-- Wortox Character Description (English)
STRINGS.CHARACTER_DESCRIPTIONS.wortox = "*Is a mischievous imp \n*Is only hungry for souls \n*Tolerates sanity and monster foods \n*Can hop through time and space \n*Makes others insane if he is too"
