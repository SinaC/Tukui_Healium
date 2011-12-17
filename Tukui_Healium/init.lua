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