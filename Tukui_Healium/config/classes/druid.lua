local ADDON_NAME, ns = ...

ns.SpellLists["DRUID"] = {
	[3] = { -- Guardian
		spells = {
			[2] = { id = 2 },
			[3] = { id = 6 },
		},
		-- spells = {
			-- [1] = { id = 13 },
			-- [2] = { id = 2 },
			-- [3] = { id = 6 },
		-- },
	},
	[4] = { -- Restoration
		buffs = {
			102352, -- Cenarion Ward heal buff
			--1126, -- Mark of the Wild (DEBUG purpose)
			162359, -- Rejuvenation (Germination)
		},
		spells = {
			[1] = { id = 1 },
			[2] = { id = 8 },
			--[4] = { id = 20 },
			[4] = { id = 4 },
			[5] = { id = 5 },
			[6] = { macroName = "NSHT" },
			--[6] = { macroName = "ABCD" },
			--[6] = { id = 3 },
			--[7] = { id = 13 },
			[7] = { id = 9 },
			[8] = { id = 12 },
			[9] = { id = 11 },
			[10] = { id = 10 },
			[11] = { id = 6 },
			--[12] = { macroName = "NSBR" },
			[12] = { id = 13 },
		},
		-- spells = {
			-- [1] = { id = 1 },
			-- [2] = { id = 8 },
			-- [3] = { id = 10 },
			-- --[4] = { id = 20 },
			-- [4] = { id = 4 },
			-- [5] = { id = 5 },
-- --			[6] = { macroName = "NSHT" },
			-- --[6] = { macroName = "ABCD" },
			-- [6] = { id = 3 },
			-- [7] = { id = 9 },
			-- [8] = { id = 13 },
			-- [9] = { id = 12 },
			-- [10] = { id = 11 },
			-- [11] = { id = 6 },
		-- },
		-- spells = {
			-- [1] = { id = 1 },
			-- [2] = { id = 8 },
			-- [3] = { id = 10 },
			-- --{ id = 20 },
			-- [6] = { id = 4 },
			-- [7] = { id = 5 },
			-- [8] = { id = 3 },
			-- [9] = { id = 9 },
			-- [10] = { id = 13 },
			-- [11] = { id = 12 },
			-- [12] = { id = 11 },
			-- [13] = { id = 6 },
		-- },
	}
}