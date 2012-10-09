-- Character/Class specific Config

local _, ns = ...
local T, C, L = unpack(Tukui)

-- Aliases
local Config = ns.Config
local SpellLists = ns.SpellLists

if T.myname == "Meuhhnon" then
	Config["general"].debuffFilter = "BLACKLIST"
	-- SpellLists["DRUID"][4].spells[6] = { macroName = "NSHT" } -- Nature Swiftness + Healing Touch
	-- SpellLists["DRUID"][4].spells[11] = { macroName = "NSBR" } -- Nature Swiftness + Rebirth

	-- -- TEST
	-- SpellLists["DRUID"][3] = { -- Guardian
		-- spells = {
			-- { id = 13 },
			-- { id = 2 },
			-- { id = 6 },
			-- { spellID = 18562 }, -- Swiftmend, Restoration spec spell
			-- { spellID = 123 }, -- Inexistant spell
			-- { spellID = 93402 }, -- Sunfire, Balance spec spell
			-- { spellID = 115098 }, -- Monk spell
			-- { spellID = 110309 }, -- Symbiosis, future spell
			-- { spellID = 124974 }, -- Nature's Vigil, future talent
			-- { spellID = 132469 }, -- Typhoon, selected talent
		-- },
	-- }
	-- SpellLists["DRUID"][4] = { -- Restoration
		-- spells = {
			-- { id = 13 },
			-- { id = 2 },
			-- { id = 6 },
			-- { spellID = 18562 }, -- Swiftmend, Restoration spec spell
			-- { spellID = 123 }, -- Inexistant spell
			-- { spellID = 93402 }, -- Sunfire, Balance spec spell
			-- { spellID = 115098 }, -- Monk spell
			-- { spellID = 110309 }, -- Symbiosis, future spell
			-- { spellID = 124974 }, -- Nature's Vigil, future talent
			-- { spellID = 132469 }, -- Typhoon, selected talent
		-- },
	-- }
end

if T.myname == "Enimouchet" then
	Config["general"].debuffFilter = "BLACKLIST"
end

if T.myname == "Yoog" then
	Config["general"].debuffFilter = "BLACKLIST"

	--SpellLists["SHAMAN"][3].spells[5] = { macroName = "NSHW" } -- Nature Swiftness + Greater Healing Wave
end

if T.myname == "Nigguro" then
	Config["general"].debuffFilter = "BLACKLIST"

	-- TODO: handle this
	-- -- remove Weakened soul from blacklist(6788)
	-- if C["blacklist"] then
		-- Private.TRemoveByVal(C["blacklist"], 6788)
	-- end

	-- Test display value
	-- SpellLists["PRIEST"][1].buffs = {
		-- { spellID = 89485, display = "value1" }, -- Inner Focus
		-- 111759, -- Levitate
	-- }
	--SpellLists["PRIEST"][1].spells[1] = { spellID = 17, debuffs = { 6788 }, display = "value1" } -- Power Word: Shield not castable if affected by Weakened Soul (6788) TODO: except if caster is affected by Divine Insight
end

--------------------------------------------------------------

if T.myname == "Holycrap" then
	Config["general"].maxButtonCount = 15
	Config["general"].dispelAnimation = "NONE"
	Config["general"].debuffFilter = "BLACKLIST"

	SpellLists["PRIEST"][1].spells = {
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

	SpellLists["PRIEST"][2].spells = {
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
	Config["general"].debuffFilter = "BLACKLIST"
	SpellLists["SHAMAN"][3].spells = {
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

if T.myname == "Noctissia" then
	Config["general"].debuffFilter = "BLACKLIST"
	SpellLists["SHAMAN"][3].spells = {
		{ id = 3 }, -- Earth Shield
		{ id = 6 }, -- Riptide
		{ id = 1 }, -- Healing Wave
		--{ macroName = "NSHW" }, -- Nature Swiftness + Greater Healing Wave
		{ id = 7 }, -- Greater Healing Wave
		{ id = 2 }, -- Chain Heal
		{ id = 4 }, -- Healing Surge
		{ id = 5 }, -- Cleanse Spirit
	}
end
