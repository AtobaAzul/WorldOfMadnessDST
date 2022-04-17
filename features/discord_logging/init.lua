-- CREDITS
-- All credit for this feature goes to Kova from DFT: https://github.com/IamFlea
-- The reason this is provided in the World of Madness mod is that the author has not created a workshop item that is easily downloadable/manageable.
-- For convenience, this is included with permission in the mod, but disabled by default.

-- Check to see whether the discord URL is valid
if string.starts(GetModConfigData("DiscordLogging"), "DISCORD_WEBHOOKS") then

    -- Imports
    modimport("features/discord_logging/discord_push.lua")
    modimport("features/discord_logging/console_command_overrides.lua")

end
