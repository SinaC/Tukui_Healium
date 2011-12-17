local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

C["healium"] = {
	["unitframes"] = {
		width = 120,
		height = 28,
	},

	["general"] = { -- will override Healium_Core config
		buttonTooltipAnchor = TukuiTooltipAnchor,
		showOOR = false
	},
}
