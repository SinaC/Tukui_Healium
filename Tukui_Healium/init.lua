local ADDON_NAME, ns = ...

-- Addon namespaces
ns.Private = {}
ns.Locales = {}
ns.Config = {}
ns.SpellLists = {}

-- ADDON LOADED always trigger before PLAYER_ENTERING_WORLD
local SavedVariablesFrame = CreateFrame("Frame")
SavedVariablesFrame:RegisterEvent("ADDON_LOADED")
SavedVariablesFrame:SetScript("OnEvent", function(self, event, addon)
	-- Only for this addon
	if event == "ADDON_LOADED" and addon == ADDON_NAME then
		local version = GetAddOnMetadata(ADDON_NAME, "version") -- get current addon version
		-- Create saved variables if not yet created
		if not TukuiHealiumDataPerCharacter or not TukuiHealiumDataPerCharacter.settings then
			TukuiHealiumDataPerCharacter = {}
			TukuiHealiumDataPerCharacter.version = version
			TukuiHealiumDataPerCharacter.enabled = true -- NOT YET USED
			TukuiHealiumDataPerCharacter.settings = { -- enabled for each spec by default
				[1] = {
					enabled = true,
				},
				[2] = {
					enabled = true,
				},
				[3] = {
					enabled = true,
				},
				[4] = {
					enabled = true,
				},
			}
		end
		TukuiHealiumDataPerCharacter.show = nil -- remove outdated entry

		-- Version check
		local lastVersion = TukuiHealiumDataPerCharacter.version -- get saved addon version
		TukuiHealiumDataPerCharacter.version = version -- set current addon version
		if lastVersion ~= TukuiHealiumDataPerCharacter.version then
			-- TODO: compatibility version
		end
	end
end)