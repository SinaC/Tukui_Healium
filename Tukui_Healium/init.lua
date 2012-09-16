local ADDON_NAME, ns = ...

-- Addon namespaces
ns.Private = {}
ns.Locales = {}
ns.Config = {}
ns.SpellLists = {}

local SavedVariablesFrame = CreateFrame("Frame")
SavedVariablesFrame:RegisterEvent("ADDON_LOADED")
-- SavedVariablesFrames:RegisterEvent("PLAYER_LOGOUT")
SavedVariablesFrame:SetScript("OnEvent", function(self, event, addon)
	-- Only for this addon
	if event == "ADDON_LOADED" and addon == ADDON_NAME then
		local version = GetAddOnMetadata(ADDON_NAME, "version") -- get current addon version
		-- Create saved variables if not yet created
		if not TukuiHealiumDataPerCharacter then
			TukuiHealiumDataPerCharacter = {}
			TukuiHealiumDataPerCharacter.version = version
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
	-- elseif event == "PLAYER_LOGOUT" then
		-- TukuiHealiumDataPerCharacter = ns.DataPerCharacter
	end
end)