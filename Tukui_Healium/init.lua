local ADDON_NAME, ns = ...
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

if not C["unitframes"].enable == true then
	print("Unitframes disabled, no healium integration")
	ns.Enabled = false
	return
end

ns.Enabled = true

-- Initialize Healium
H:Initialize(C["healium"])
-- Display version
local libVersion = GetAddOnMetadata("Healium_Core", "Version")
if libVersion then
	print(string.format(L.healium_GREETING_VERSION, tostring(libVersion)))
else
	print(L.healium_GREETING_VERSIONUNKNOWN)
end
print(L.healium_GREETING_OPTIONS)

local killBlizzardFrames = CreateFrame("Frame")
killBlizzardFrames:RegisterEvent("PLAYER_LOGIN")
killBlizzardFrames:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		-- Kill blizzard raid frames
		local dummy = function() return end
		local function Kill(object)
			if object.UnregisterAllEvents then
				object:UnregisterAllEvents()
			end
			object.Show = dummy
			object:Hide()
		end
		InterfaceOptionsFrameCategoriesButton10:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
		InterfaceOptionsFrameCategoriesButton11:SetScale(0.00001)
		InterfaceOptionsFrameCategoriesButton11:SetAlpha(0)
		Kill(CompactRaidFrameManager)
		Kill(CompactRaidFrameContainer)
		CompactUnitFrame_UpateVisible = dummy
		CompactUnitFrame_UpdateAll = dummy
	end
end)