-- Wolfram Model:
-- 1 - (1 - x)^k, x=(y * z), k=6, y=1/2, z=.41
-- x: chance of a single transmission event (combination of both y and z chances)
-- y: Black Death default mod chance of spreading to nearby entities when something is infected
-- z: World of Madness VIRUS_TRANSMIT_RATE
-- k: How many 5 second segments have passed (Black Death sends a spread event every 5 seconds on average)

-- Spread Chance (y = 1/2):
-- 20% spread chance: 05 seconds
-- 50% spread chance: 15 seconds
-- 75% spread chance: 30 seconds
-- 87% spread chance: 45 seconds
-- 94% spread chance: 60 seconds

-- Contact transmission (y = 10/11):
-- 37% spread chance: 1 hit
-- 60% spread chance: 2 hits
-- 75% spread chance: 3 hits

VIRUS_TRANSMIT_RATE = 0.41
DEADLY_VIRUS_CHANCE = 0.35

VIRUS_CANNON_USES = 25
VIRUS_CANNON_DAMAGE = 24
VIRUS_CANNON_SOAP_RANGE = 5

VIRUS_MED_BAD_CHANCE = 0.75
VIRUS_MED_HINT_CHANCE = 0.5

VIRUS_MANDRAKE_SPAWN_CHANCE = 0.5

-- Creatures with immunity list
VIRUS_IMMUNITY_LIST = 
{
    "chester",
    "hutch",
    "glommer",
    "wobysmall",
    "wobybig",
    "bernie_inactive",
    "bernie_active",
    "bernie_big",
    "friendlyfruitfly"
}
