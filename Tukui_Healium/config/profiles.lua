-- Character/Class specific config

local _, ns = ...
local T, C, L = unpack(Tukui)
local config = ns.config
local spellLists = ns.spellLists

if T.myname == "Meuhhnon" then
	config["general"].debuffFilter = "BLACKLIST"
	spellLists["DRUID"][4].spells[6] = { macroName = "NSHT" } -- Nature Swiftness + Healing Touch
	spellLists["DRUID"][4].spells[11] = { macroName = "NSBR" } -- Nature Swiftness + Rebirth
end

if T.myname == "Enimouchet" then
	config["general"].debuffFilter = "BLACKLIST"
end

if T.myname == "Yoog" then
	config["general"].debuffFilter = "BLACKLIST"

	--spellLists["SHAMAN"][3].spells[5] = { macroName = "NSHW" } -- Nature Swiftness + Greater Healing Wave
end

if T.myname == "Nigguro" then
	config["general"].debuffFilter = "BLACKLIST"

	-- TODO: handle this
	-- -- remove Weakened soul from blacklist(6788)
	-- if C["blacklist"] then
		-- Private.TRemoveByVal(C["blacklist"], 6788)
	-- end
end

--------------------------------------------------------------

if T.myname == "Holycrap" then
	config["general"].maxButtonCount = 15
	config["general"].dispelAnimation = "NONE"
	config["general"].debuffFilter = "BLACKLIST"

	spellLists["PRIEST"][1].spells = {
		{ id = 13 }, -- Pain Suppression
		{ id =  1 }, -- Power Word: Shield
		{ id = 15 }, -- Penance
		{ id =  2 }, -- Renew
		{ id =  7 }, -- Heal
		{ id =  8 }, -- Greater Heal
		{ id =  9 }, -- Flash Heal
		{ id = 12 }, -- Prayer of Mending
		{ id = 11 }, -- Binding Heal
		{ id =  5 }, -- Prayer of Healing
		{ id =  3 }, -- Dispel Magic
		{ id =  4 }, -- Cure Disease
		{ id = 19 }, -- Power Infusion
		{ id = 17 }, -- Leap of Faith
	}

	spellLists["PRIEST"][2].spells = {
		{ id =  1 }, -- Power Word: Shield
		{ id =  2 }, -- Renew
		{ id =  7 }, -- Heal
		{ id = 12 }, -- Prayer of Mending
		{ id =  9 }, -- Flash Heal
		{ id =  8 }, -- Greater Heal
		{ id = 11 }, -- Binding Heal
		{ id =  5 }, -- Prayer of Healing
		{ id = 14 }, -- Circle of Healing (Holy)
		{ id =  3 }, -- Dispel Magic
		{ id =  4 }, -- Cure Disease
		{ id = 16 }, -- Guardian Spirit (Holy)
		{ id = 17 }, -- Leap of Faith
	}
end

if T.myname == "Boombella" then
	config["general"].debuffFilter = "BLACKLIST"
	spellLists["SHAMAN"][3].spells = {
		{ id = 3 }, -- Earth Shield
		{ id = 6 }, -- Riptide
		{ id = 1 }, -- Healing Wave
		{ id = 7 }, -- Greater Healing Wave
		{ id = 2 }, -- Chain Heal
		{ id = 4 }, -- Healing Surge
		{ id = 5 }, -- Cleanse Spirit
	}
end

--------------------------------------------------------------

if T.myname == "Veglagai" then
	config["general"].debuffFilter = "BLACKLIST"
	spellLists["SHAMAN"][3].spells = {
		{ id = 3 }, -- Earth Shield
		{ id = 6 }, -- Riptide
		{ id = 1 }, -- Healing Wave
		{ macroName = "NSHW" }, -- Nature Swiftness + Greater Healing Wave
		{ id = 2 }, -- Chain Heal
		{ id = 4 }, -- Healing Surge
		{ id = 5 }, -- Cleanse Spirit
	}
end
