local ADDON_NAME, ns = ...

-- Create saved variables if not yet created
if not TukuiHealiumDataPerCharacter then
	TukuiHealiumDataPerCharacter = {}
	TukuiHealiumDataPerCharacter.show = true
-- TODO: per spec
-- if value doesn't exist for one spec, get value from another one, if no value exists for any spec, set to true
end

-- Version check
local lastVersion = TukuiHealiumDataPerCharacter.version -- get saved addon version
TukuiHealiumDataPerCharacter.version = GetAddOnMetadata(ADDON_NAME, "version") -- get current addon version
if lastVersion ~= TukuiHealiumDataPerCharacter.version then
	-- TODO: compatibility version
end

-- Local namespaces
ns.Private = {}
ns.Locales = {}