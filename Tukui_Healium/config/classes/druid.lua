local ADDON_NAME, ns = ...

ns.SpellLists["DRUID"] = {
	[3] = { -- Guardian
		spells = {
			{ id = 13 },
			{ id = 2 },
			{ id = 6 },
		},
	},
	[4] = { -- Restoration
		buffs = {
			102352, -- Cenarion Ward heal buff
			--1126, -- Mark of the Wild (DEBUG purpose)
		},
		spells = {
			{ id = 1 },
			{ id = 8 },
			{ id = 10 },
			{ id = 4 },
			{ id = 5 },
			{ id = 3 },
			{ id = 9 },
			{ id = 13 },
			{ id = 12 },
			{ id = 11 },
			{ id = 6 },
		},
	}
}