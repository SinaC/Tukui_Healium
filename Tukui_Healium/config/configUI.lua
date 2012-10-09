local _, ns = ...
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

-- TODO: fix this, why I can't access this constants from wow API
local MAX_ACCOUNT_MACROS = MAX_ACCOUNT_MACROS or 36
local MAX_CHARACTER_MACROS = MAX_CHARACTER_MACROS or 18

if T.myname ~= "Meuhhnon" and T.myname ~= "Enimouchet" and T.myname ~= "Nigguro" and T.myname ~= "Yoog" then return end -- Only for me =)

local Config = ns.Config
local SpellLists = ns.SpellLists
local Private = ns.Private
local B = ns.Builder

local CurrentlySelectedSpecConfiguration = 0 -- index of spec currently configured

local hoverColor = T.UnitColor.class[T.myclass]
local selectColor = { T.UnitColor.class[T.myclass][1], T.UnitColor.class[T.myclass][2], T.UnitColor.class[T.myclass][3], 0.8 }

local function __DumpConfigEntry(entry)
	local valueStr = ""
	if entry and type(entry) == "table" then
		valueStr = "("
		for k, v in pairs(entry) do
			valueStr = valueStr .. tostring(k).."=>"..tostring(v)
		end
		valueStr = valueStr .. ")"
	else
		valueStr = tostring(entry)
	end
	return valueStr
end

local function __DumpConfig(config, default)
	for k, v in pairs(config) do
		local valueStr = __DumpConfigEntry(v)
		print(tostring(k).."==>"..tostring(valueStr)..(k == default and " ***" or ""))
	end
end

--[[
	General config (needs reload UI)
		enabled
		width
		height
		buttonTooltip
		buffTooltip
		debuffTooltip
		showBuff: left, on button, hidden
		showDebuff: right, priority, hidden
		showShields
		showGlow
		showOOM
		showOOR
		dispelAnimation
		highlightDispel
		dispelSound
		playSoundOnDispel
	Colors
		unitDead
		unitOOR
		spellPrereqFailed
		spellNotUsable
		OOM
	Spec config[1->4]
		enabled
		debuffFilter: dispellable, blacklist, none
	Buff
		TO DEFINE (list of buff)
	Blacklist
		TO DEFINE (list of debuff)
	No Highlight
		TO DEFINE (list of debuff)
	Shields
		TO DEFINE (list of shields)
--]]

local GeneralOptions = {
	enabled = true,
	debug = 1000,
	--debugDebuff = "Curse",

	showOOM = true,						-- color heal button in blue when OOM
	showOOR = false,					-- very time consuming and not really useful if unitframes are already tagged as OOR

	maxButtonCount = 15,				-- maximum number of buttons
	--buttonSpacing = 2,					-- distance between 2 buttons
	showButtonTooltip = true,			-- display heal buttons tooltip
	buttonTooltipAnchor = nil, 			-- debuff tooltip anchor (nil means button itself)--(ElvUI and _G["TooltipHolder"]) or (Tukui and _G["TukuiTooltipAnchor"])

	showGlow = false,					-- show glowing spell when proc activated -> !!!! protected calls exception  seems to work if using Tukui_Healium

	showBuff = "LEFT",					-- display buff castable by configured spells
	maxBuffCount = 6,					-- maximum number of buff displayed
	--buffSpacing = 2,					-- distance between 2 buffs
	showBuffTooltip = true,				-- display buff tooltip
	buffTooltipAnchor = nil,			-- buff tooltip anchor (nil means buff itself)

	showDebuff = "RIGHT",				-- display debuff
	maxDebuffCount = 8,					-- maximum number of debuff displayed
	--debuffSpacing = 2,				-- distance between 2 debuffs
	showDebuffTooltip = true,			-- display debuff tooltip
	debuffTooltipAnchor = nil,			-- debuff tooltip anchor (nil means debuff itself)

	showShields = true,					-- show absorb shield remaining value see \config\filters\shields.lua

	-- DISPELLABLE: show only dispellable debuff
	-- BLACKLIST: exclude non-dispellable debuff from list
	-- WHITELIST: include non-dispellable debuff from list
	-- NONE: show every non-dispellable debuff
	debuffFilter = "WHITELIST",
	highlightDispel = true,				-- highlight dispel button when debuff is dispellable (no matter they are shown or not but only if not in dispellable filter)
	playSoundOnDispel = true,			-- play a sound when a debuff is dispellable (no matter they are shown or not but only if not in dispellable filter)
	dispelSoundFile = "Sound\\Doodad\\BellTollHorde.wav",
	-- FLASH: flash button
	-- BLINK: blink button
	-- PULSE: pulse button
	-- NONE: no flash
	dispelAnimation = "NONE", --"PULSE", 			-- animate dispel button when debuff is dispellable (no matter they are shown or not but only if not in dispellable filter)

	width = 140,
	height = 40,
	stringKey = "tsekwa",
	testColor = {1.0, 0.5, 0.5},
	testMulti = {"a", "c", "e" },
}

local ColorOptions = {
	unitDead = {1, 0.1, 0.1},
	unitOOR = {1.0, 0.3, 0.3},
	spellPrereqFailed = {0.2, 0.2, 0.2},
	spellNotUsable = {1.0, 0.5, 0.5},
	OOM = {0.5, 0.5, 1.0},
}

local SpecOptions = {
	enabled = true,
	debuffFilter = "BLACKLIST"
}

local BlacklistOptions = {
	[1] = 6788,		-- Weakened Soul
	[2] = 26218,	-- Mistletoe
	[3] = 57724,	-- Berserk
	[4] = 57723,	-- Time Warp
	[5] = 80354,	-- Ancient Hysteria
	[6] = 36032,	-- Arcane Blast
	[7] = 36893,	-- Transporter Malfunction
	[8] = 95223,	-- Recently Mass Resurrected
	[9] = 24755,	-- Tricked or Treated
	[10] = 26013,	-- Deserter
	[11] = 71041,	-- Dungeon Deserter
	[12] = 99413,	-- Deserter
	[13] = 97821,	-- Void-Touched
	[14] = 106368,	-- Twilight Shift
	[15] = 124274,	-- Moderate Stagger
	[16] = 124275,	-- Light Stagger (Monk tank debuff)
}

local NoHighlightListOptions = {
	-- Zul Gurub
	[1] = 96326, -- Burning Blood
	[2] = 96325, -- Frostburn Formula
	[3] = 96328, -- Toxic Torment
	-- Misc
	[4] = 91291, -- Drain Life
}


--[[
Option definition entry explanation:
---------------------------------
	key: key in config, used to get/set value if no get/set method are specfied
	name: name displayed
	description: tooltip description
	type: toggle, number, string, select
		toggle: on/off
		number: positive integer value
			min: minimum value
			max: maximum value
			step: stop value [default: 1]
		string: string
		select: select of value from a list
			values: list of values (function or table)   prototype values(entry, config) return {values}
				value: value to store in config
				text: description of value
				icon: icon related to value
		color: color picker
		anchor: {point, relativeFrame, relativePoint, offsetX, offsetY}
		custom: custom config
			build: build option GUI. prototype build(parent, offset, entry, config) return height
	get: get current value if key is not specified. prototype get(entry, config) return value
	set: set current value if key is not specified. prototype set(value, entry, config)
	default: default value
	reloadui: a complete reloadui must be done when modifying this config
--]]
local GeneralOptionsDefinition = {
	[1] = {
		key = "enabled",
		name = "Enable globally", -- TODO: locales
		description = "Enable globally. If not enabled, addon it not loaded when connecting this alt", -- TODO: locales
		type = "toggle",
		default = true,
		reloadui = true,
	},
	[2] = {
		key = "width",
		name = "Width", -- TODO: locales
		description = "Unitframes width", -- TODO: locales
		type = "number",
		min = 80,
		max = 160,
		default = 120,
		reloadui = true,
	},
	[3] = {
		key = "height",
		name = "Height", -- TODO: locales
		description = "Unitframe height", -- TODO: locales
		type = "number",
		min = 20,
		max = 40,
		default = 28,
		reloadui = true,
	},
	[4] = {
		key = "showButtonTooltip",
		name = "Button tooltip",
		description = "Show tooltip on button",
		type = "toggle",
		default = true,
		reloadui = true,
	},
	[5] = {
		key = "showBuffTooltip",
		name = "Buff tooltip",
		description = "Show tooltip on buff",
		type = "toggle",
		default = false,
		reloadui = true,
	},
	[6] = {
		key = "showDebuffTooltip",
		name = "Debuff tooltip",
		description = "Show tooltip on debuff",
		type = "toggle",
		default = false,
		reloadui = true,
	},
	[7] = {
		key = "showBuff",
		name = "Buff", -- TODO: locales
		description = "Buff look&feel", -- TODO: locales
		type = "select",
		values = {
			[1] = { value = "LEFT", text = "Left" }, -- TODO: locales
			[2] = { value = "BUTTON", text = "Button border" }, -- TODO: locales
			[3] = { value = "HIDDEN", text = "Not displayed" }, -- TODO: locales
		},
		default = "LEFT",
		reloadui = true,
	},
	[8] = {
		key = "showDebuff",
		name = "Debuff", -- TODO: locales
		description = "Debuff look&feel", -- TODO: locales
		type = "select",
		values = {
			[1] = { value = "RIGHT", text = "Right" },
			[2] = { value = "BUTTON", text = "Button border" }, -- TODO: locales
			[3] = { value = "HIDDEN", text = "Not displayed" }, -- TODO: locales
		},
		default = "RIGHT",
		reloadui = true,
	},
	[9] = {
		key = "showShields",
		name = "Shields", -- TODO: locales
		description = "Shields displayed", -- TODO: locales
		type = "toggle",
		default = false,
		reloadui = true,
	},
	[10] = {
		key = "showOOM",
		name = "OOM",
		description = "Change button color when OOM",
		type = "toggle",
		default = true,
		reloadui = true,
	},
	[11] = {
		key = "showOOR",
		name = "OOR",
		description = "Change button color when OOR.\nVery CPU consuming (per column check).\nUse it only if your UI doesn't display this information",
		type = "toggle",
		default = false,
		reloadui = true
	},
	[12] = {
		key = "stringKey",
		name = "Whatever",
		description = "Test string option",
		type = "string",
		default = "my test string",
		reloadui = true
	},
	[13] = {
		key = "testColor",
		name = "Color",
		description = "Test color",
		type = "color",
		default = {1, 0, 0, 1}, -- red
		reloadui = true
	},
	[14] = {
		key = "testMulti",
		name = "Multi",
		description = "Test multiple checkboxes",
		type = "multiselect",
		values = {
			[1] = { value = "a", text = "Advocaat" },
			[2] = { value = "b", text = "Beer" },
			[3] = { value = "c", text = "Cointreau" },
			[4] = { value = "d", text = "Drambuie" },
			[5] = { value = "e", text = "Ethanol" },
			[6] = { value = "f", text = "Fernet" },
		},
		default = {"a"},
		reloadui = true,
	},
}

local ColorOptionsDefinition = {
	[1] = {
		key = "unitDead",
		name = "Dead",
		description = "Color when unit is dead",
		type = "color",
		default = {1, 0.1, 0.1}, -- TODO: get color from Tukui
		reloadui = true
	},
	[2] = {
		key = "unitOOR",
		name = "Out-of-range",
		description = "Color when unit out-of-range",
		type = "color",
		default = {1.0, 0.3, 0.3}, -- TODO: get color from Tukui
		reloadui = true
	},
	[3] = {
		key = "spellPrereqFailed",
		name = "Prerequisites failed",
		description = "Color when unit buff/debuff doesn't match spell prerequisites",
		type = "color",
		default = {0.2, 0.2, 0.2},
		reloadui = true
	},
	[4] = {
		key = "spellNotUsable",
		name = "Not usable",
		description = "Color when spell is not usabled",
		type = "color",
		default = {1.0, 0.5, 0.5}, -- TODO: get color from Tukui
		reloadui = true
	},
	[5] = {
		key = "OOM",
		name = "Out of mana",
		description = "Color when player is out-of-mana to cast spell",
		type = "color",
		default = {0.5, 0.5, 1.0},
		reloadui = true
	},
}

local SpecOptionsDefinition = {
	[1] = {
		key = "enabled",
		name = "Enabled",
		description = "Enabled for this spec",
		type = "toggle",
		default = true,
		reloadui = true
	},
	[2] = {
		key = "debuffFilter",
		name = "Debuff Filter",
		description = "Filter applied on debuff",
		type = "select",
		values = {
			[1] = { value = "BLACKLIST", text = "Only if not blacklisted" }, -- TODO: locales
			[2] = { value = "DISPELLABLE", text = "Only if dispellable" }, -- TODO: locales
			[3] = { value = "NOFILTER", text = "No filter" }, -- TODO: locales
		},
		default = "BLACKLIST",
		reloadui = true
	}
}

------------------------
-- Custom macro or spell
local SpellListValues = nil
local function SpellListGetValues() -- return a list of predefined spell for current class
	if SpellListValues then
		return SpellListValues -- return existing list if already built
	end
	local classConfig = HealiumCore[2][T.myclass]
	if not classConfig then
		return nil
	else
		local predefined = classConfig.predefined
		if not predefined then
			return nil
		else
			SpellListValues = {}
			for index, spell in ipairs(predefined) do
				local spellID = spell.spellID
				local spellName, _, spellIcon = GetSpellInfo(spellID)
				local entry = { value = index, text = spellName, icon = spellIcon }
				tinsert(SpellListValues, entry)
			end
			-- -- add no spell
			--tinsert(SpellListValues, { value = 0, text = "No spell", icon = "Interface/Icons/INV_Misc_QuestionMark" })
			return SpellListValues
		end
	end
end

local function MacroListGetValues()
	local MacroListValues = {}
	local numAccountMacros, numCharacterMacros = GetNumMacros()
--print("#macro:"..tostring(numAccountMacros).."  "..tostring(numCharacterMacros).."  "..tostring(MAX_ACCOUNT_MACROS))
	-- account macro
	for i = 1, numAccountMacros do
		local macroIndex = i
		local name, iconTexture = GetMacroInfo(macroIndex)
--print("MACROACCOUNT["..tostring(macroIndex).."]:"..tostring(name).."  "..tostring(iconTexture))
		if not name then break end
		local entry = { value = name, text = name, icon = iconTexture }
		tinsert(MacroListValues, entry)
	end
	-- character macro
	for i = 1, numCharacterMacros do
		local macroIndex = MAX_ACCOUNT_MACROS + i
		local name, iconTexture = GetMacroInfo(macroIndex)
--print("MACROCHARACTER["..tostring(macroIndex).."]:"..tostring(name).."  "..tostring(iconTexture))
		if not name then break end
		local entry = { value = name, text = name, icon = iconTexture }
		tinsert(MacroListValues, entry)
	end
	-- -- add no macro
	--tinsert(MacroListValues, { value = 0, text = "No macro", icon = "Interface/Icons/INV_Misc_QuestionMark" })
	return MacroListValues
end

----
local function MacroOrSpellGetValue(option, config)
	local value = config[option.key]
-- print("MacroOrSpellGetValue:"..tostring(option.key).." => "..__DumpConfigEntry(value))
	return value
end

local function MacroOrSpellSetValue(key, value, option, config)
--print("MacroOrSpellSetValue:"..tostring(key).."   "..tostring(value))
	if not key or not value then
		config[option.key] = nil
	else
		config[option.key] = { [key] = value }
	end
--__DumpConfig(config, option.key)

	local specName = (type(CurrentlySelectedSpecConfiguration) == "number") and (select(2, GetSpecializationInfo(CurrentlySelectedSpecConfiguration))) or CurrentlySelectedSpecConfiguration
	H:RegisterSpellList(specName, config)
end

local function MacroOrSpellDropdownItemHandler(self)
	UIDropDownMenu_SetSelectedID(self.owner, self:GetID())
	for k, v in pairs(self.owner.subDropdowns) do
		if k == self.value then
			v:Show()
		else
			v:Hide()
		end
	end
	self.owner.currentValue = self.value
	local subDropdown = self.owner.subDropdowns[self.value]
	local subValue = subDropdown.currentValue
--print("MacroOrSpellDropdownItemHandler:"..tostring(self.value).."  "..tostring(subValue).."  "..tostring(subDropdown).."  "..tostring(self.owner.currentValue))
	MacroOrSpellSetValue(self.value, subValue, self.owner.option, self.owner.config)

--	__DumpConfig(self.owner.config)
end
local function MacroOrSpellDropdownInitialize(self, level)
--print("MacroOrSpellDropdownInitialize:"..tostring(self))
	self.currentValue = nil
	local currentValue = MacroOrSpellGetValue(self.option, self.config)
	local index = 1
	for k, v in pairs(self.subDropdowns) do
		local node = UIDropDownMenu_CreateInfo()
		node.text = v.text
		node.value = k -- or v.key
		node.owner = self
		node.func = MacroOrSpellDropdownItemHandler
		UIDropDownMenu_AddButton(node, level)
		if currentValue and currentValue[k] then
--print("current:"..tostring(k))
			self.currentValue = k
			UIDropDownMenu_SetSelectedID(self, index)
			v:Show()
		end
		index = index + 1
	end
	if not self.currentValue then
		self.selectedID = nil -- didn't find unselect method
		UIDropDownMenu_Refresh(self)
		UIDropDownMenu_SetText(self, "")
		for k, v in pairs(self.subDropdowns) do
			v:Hide()
		end
	end
end

local function MacroOrSpellSubDropdownItemHandler(self)
	UIDropDownMenu_SetSelectedID(self.owner, self:GetID())
	self.owner.currentValue = self.value
	local parentDropdown = self.owner.parentDropdown
	local parentValue = parentDropdown.currentValue
--print("MacroOrSpellSubDropdownItemHandler:"..tostring(parentValue).."  "..tostring(self.value).."  "..tostring(parentDropdown).."  "..tostring(self.owner.currentValue))
	MacroOrSpellSetValue(parentValue, self.value, self.owner.parentDropdown.option, self.owner.parentDropdown.config)

--	__DumpConfig(self.owner.parentDropdown.config)
end
local function MacroOrSpellSubDropdownInitialize(self, level)
--print("MacroOrSpellSubDropdownInitialize:"..tostring(self.key).."  "..tostring(self))
	self.currentValue = nil
	local currentValue = MacroOrSpellGetValue(self.parentDropdown.option, self.parentDropdown.config)
	local values = self.values()
	if values then
		for index, desc in pairs(values) do
			local node = UIDropDownMenu_CreateInfo()
			node.text = desc.text
			node.value = desc.value
			node.icon = desc.icon
			node.owner = self
			node.func = MacroOrSpellSubDropdownItemHandler
			UIDropDownMenu_AddButton(node, level)
			if currentValue and currentValue[self.key] == desc.value then
--print("current sub:"..tostring(self.key).." "..tostring(desc.value))
				self.currentValue = desc.value
				UIDropDownMenu_SetSelectedID(self, index)
			end
		end
	end
	if not self.currentValue then
		self.selectedID = nil -- didn't find unselect method
		UIDropDownMenu_Refresh(self)
		UIDropDownMenu_SetText(self, "")
	end
end

local function MacroOrSpellClearButtonHandler(button)
-- print("BEFORE:")
-- __DumpConfig(button.config, button.option.key)

	-- clear entry
	--button.config[button.option.key] = nil
	MacroOrSpellSetValue(nil, nil, button.option, button.config)

-- print("AFTER:")
-- __DumpConfig(button.config, button.option.key)

	-- refresh dropdown
	for _, subDropdown in pairs(button.parentDropdown.subDropdowns) do
		UIDropDownMenu_Initialize(subDropdown, MacroOrSpellSubDropdownInitialize)
	end
	UIDropDownMenu_Initialize(button.parentDropdown, MacroOrSpellDropdownInitialize)
end

local function BuildMacroOrSpellEntry(parent, name, offset, option, config)
	-- label
	local label = B:CreateLabel(parent, name.."_BuildMacroOrSpellEntry_"..option.name.."_LABEL", option.name, 100, 20)
	label:SetPoint("TOPLEFT", 5, -(offset))

	-- dropdown macro/spell
	local dropdownTypeName = name.."_BuildMacroOrSpellEntry_"..option.name.."_DROPDOWNTYPE"
	local dropdownType = _G[dropdownTypeName]
	if not dropdownType then
		dropdownType = CreateFrame("Button", dropdownTypeName, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_JustifyText(dropdownType, "LEFT")
		--UIDropDownMenu_SetWidth(dropdownType, 100)
		--UIDropDownMenu_SetButtonWidth(dropdownType, 124)
	end
	dropdownType:SetPoint("TOPLEFT", 80, -offset)

	dropdownType.config = config
	dropdownType.option = option

	-- 2 dropdowns with spell list (id) and macro list (macro)
	local dropdownSpellName = name.."_BuildMacroOrSpellEntry_"..option.name.."_DROPDOWNSPELL"
	local dropdownSpell = _G[dropdownSpellName]
	if not dropdownSpell then
		dropdownSpell = CreateFrame("Button", dropdownSpellName, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_JustifyText(dropdownSpell, "LEFT")
		--UIDropDownMenu_SetWidth(dropdownType, 100)
		--UIDropDownMenu_SetButtonWidth(dropdownType, 124)
	end
	dropdownSpell:SetPoint("TOPLEFT", 240, -offset)
	dropdownSpell.key = "id"
	dropdownSpell.text = "spell"
	dropdownSpell.values = SpellListGetValues
	dropdownSpell:Hide()

	local dropdownMacroName = name.."_BuildMacroOrSpellEntry_"..option.name.."_DROPDOWNMACRO"
	local dropdownMacro = _G[dropdownMacroName]
	if not dropdownMacro then
		dropdownMacro = CreateFrame("Button", dropdownMacroName, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_JustifyText(dropdownMacro, "LEFT")
		--UIDropDownMenu_SetWidth(dropdownType, 100)
		--UIDropDownMenu_SetButtonWidth(dropdownType, 124)
	end
	dropdownMacro:SetPoint("TOPLEFT", 240, -offset)
	dropdownMacro.key = "macroName"
	dropdownMacro.text = "macro"
	dropdownMacro.values = MacroListGetValues
	dropdownMacro:Hide()

	-- cascading dropdown
	dropdownType.subDropdowns = {
		[dropdownSpell.key] = dropdownSpell,
		[dropdownMacro.key] = dropdownMacro
	}
	dropdownSpell.parentDropdown = dropdownType
	dropdownMacro.parentDropdown = dropdownType

	UIDropDownMenu_Initialize(dropdownSpell, MacroOrSpellSubDropdownInitialize)
	UIDropDownMenu_Initialize(dropdownMacro, MacroOrSpellSubDropdownInitialize)
	UIDropDownMenu_Initialize(dropdownType, MacroOrSpellDropdownInitialize)

	-- clear button
	local button =  B:CreateButton(parent, name.."_BuildMacroOrSpellEntry_"..option.name.."_BUTTONCLEAR", "CLEAR", 40, 20, MacroOrSpellClearButtonHandler)
	button:ClearAllPoints()
	button:SetPoint("TOPLEFT", 400, -offset)

	button.config = config
	button.option = option
	button.parentDropdown = dropdownType

	return 25
end

-- create 15 entries
local SpellListOptionsDefinition = {}
for i = 1, 15 do
	SpellListOptionsDefinition[i] = {
		key = i,
		name = "Button"..i,
		type = "custom",
		build = BuildMacroOrSpellEntry,
		optional = true,
		reloadui = true,
	}
end

-- Aura list
local DelAuraHandler -- forward declaration
local EditAuraHandler -- forward declaration
local UpdateEditAura -- forward declaration
local function RefreshAuraList(frame, name, config)
	if not frame.auras then frame.auras = {} end -- keep a list of created auras
	for index, aura in pairs(frame.auras) do -- everything is hidden by default
		aura.entryFrame:Hide()
		aura.entryFrame.spellID = nil
		aura.entryFrame.spellName = nil
		aura.entryFrame.spellIcon = nil
		aura.entryFrame.index = nil
		aura.delButton:Hide()
		aura.editButton:Hide()
	end
	local offset = 0
	for index, entry in ipairs(config) do
		local spellName, _, spellIcon = GetSpellInfo(entry)
		if not spellName then spellIcon = "INTERFACE\ICONS\INV_MISC_QUESTIONMARK" end
		-- frame
		local entryFrameName = name.."_FRAME_"..index
		local entryFrame = _G[entryFrameName]
		if not entryFrame then
			entryFrame = CreateFrame("Frame", entryFrameName, frame)
			entryFrame:SetTemplate()
			entryFrame:Size(25, 25)
		end
		entryFrame:SetPoint("TOPLEFT", 5, -(offset))
		entryFrame:Show()

		entryFrame.spellID = entry
		entryFrame.spellName = spellName
		entryFrame.spellIcon = spellIcon
		entryFrame.index = index

		-- tooltip
		entryFrame:SetScript("OnEnter", function(self)
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 7)
			GameTooltip:SetHyperlink(format("spell:%s", self.spellID))
			GameTooltip:Show()
		end)
		entryFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)

		-- icon
		local iconName = name.."_ICON_"..index
		local icon = _G[iconName]
		if not icon then
			icon = entryFrame:CreateTexture(iconName, "ARTWORK")
			icon:SetPoint("TOPLEFT", 2, -2)
			icon:SetPoint("BOTTOMRIGHT", -2, 2)
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		icon:SetTexture(spellIcon)

		-- del
		local delButton = B:CreateButton(frame, name.."_DELBUTTON_"..index, "DEL", 80, 25, DelAuraHandler)
		delButton:ClearAllPoints()
		delButton:SetPoint("LEFT", entryFrame, "RIGHT", 2, 0)
		delButton:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
		delButton:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
		delButton:Show()

		delButton.config = config
		delButton.frame = frame
		delButton.name = name
		delButton.index = index
		delButton.spellID = spellID

		-- edit
		local editButton = B:CreateButton(frame, name.."_EDITBUTTON_"..index, "EDIT", 80, 25, EditAuraHandler)
		editButton:ClearAllPoints()
		editButton:SetPoint("LEFT", delButton, "RIGHT", 2, 0)
		editButton:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
		editButton:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
		editButton:Show()

		editButton.config = config
		editButton.frame = frame
		editButton.name = name
		editButton.index = index
		editButton.spellID = spellID

		-- aura name
		local auraName = name.."_AURA_"..index
		if not frame.auras[auraName] then
			frame.auras[auraName] = {}
			frame.auras[auraName].entryFrame = entryFrame
			frame.auras[auraName].delButton = delButton
			frame.auras[auraName].editButton = editButton
		end

		offset = offset + 30
	end
	frame:Height(offset)
end

DelAuraHandler = function(button)
-- print("DELAURAHANDLER:"..tostring(button.index).."  "..tostring(#button.config))
-- print("BEFORE:"..tostring(#button.config))
-- for k, v in ipairs(button.config) do
-- print(tostring(k).."=>"..tostring(v))
-- end
	-- remove entry
	for i = button.index, #button.config-1 do
		button.config[i] = button.config[i+1]
	end
	tremove(button.config, #button.config)
-- print("AFTER:"..tostring(#button.config))
-- for k, v in ipairs(button.config) do
-- print(tostring(k).."=>"..tostring(v))
-- end
	RefreshAuraList(button.frame, button.name, button.config)
end

EditAuraHandler = function(button)
--print("EDITAURAHANDLER:"..tostring(button.index))
	local spellID = button.config[button.index]
	button.frame.editPanel.editButton = button
	button.frame.editPanel.spellID = spellID
	button.frame.editPanel.spellIDEditbox:SetText(tostring(spellID)) -- set spellID
	button.frame.editPanel:ClearAllPoints()
	button.frame.editPanel:SetPoint("TOPLEFT", button, "TOPRIGHT", 25, 0)
	UpdateEditAura(button.frame.editPanel) -- refresh edit box
end

local function AddAuraHandler(button)
	-- show edit panel
	button.frame.editPanel.editButton = nil
	button.frame.editPanel.spellID = nil
	button.frame.editPanel:ClearAllPoints()
	button.frame.editPanel:SetPoint("TOPRIGHT", button.frame, "TOPRIGHT", -25, 0)
	UpdateEditAura(button.frame.editPanel) -- refresh edit box
end

local function EditAuraApplyHandler(button)
	-- if editButton not nil -> edit, add otherwise (if not already in list)
	if button.frame.editPanel.spellID and button.frame.editPanel.spellID ~= "" then
		local change = false
		if button.frame.editPanel.editButton then
			-- edit
			-- check if value has changed
			if button.config[button.frame.editPanel.editButton.index] ~= button.frame.editPanel.spellID then
--print("MODIFIED")
				change = true
				button.config[button.frame.editPanel.editButton.index] = button.frame.editPanel.spellID
--			else
--print("UNMODIFIED")
			end
		else
			-- add
			-- check if already in list
			local found = false
			for index, spellID in ipairs(button.config) do
				if spellID == button.frame.editPanel.spellID then
					found = true
					break
				end
			end
			if not found then
				-- create a new entry
--print("NEW")
				tinsert(button.config, button.frame.editPanel.spellID)
				change = true
--			else
--print("DUPLICATE")
			end
		end
		if change then
			RefreshAuraList(button.frame, button.name, button.config)
		end
	-- else
-- print("INVALID SPELLID")
	end
	-- hide edit panel & remove saved info
	button.frame.editPanel.editButton = nil
	button.frame.editPanel.spellID = nil
	button.frame.editPanel:Hide()
end

local function EditAuraCancelHandler(button)
	-- hide edit panel & remove saved info
	button:GetParent().editButton = nil
	button:GetParent().spellID = nil
	button:GetParent():Hide()
end

local function EditSpellIDHandler(button)
	button:GetParent().spellID = tonumber(button:GetText())
	UpdateEditAura(button:GetParent())
end

UpdateEditAura = function(editPanel)
	local spellName, _, spellIcon = GetSpellInfo(editPanel.spellID)
	if not spellName then -- invalid
		editPanel.spellIDEditbox:SetText("") -- reset spellID
		editPanel.spellName:SetText("") -- reset spell name
		editPanel.spellID = nil
		editPanel.iconFrame.icon:SetTexture(nil)
	else
		editPanel.spellName:SetText(spellName) -- set spell name
		editPanel.iconFrame.icon:SetTexture(spellIcon) -- set icon
	end
	--editPanel.spellIDEditbox:SetFocus()
	-- show edit panel
	editPanel:Show()
end

local function CreateAuraPanel(parent, name, config)
	local frame = _G[name]
	if not frame then frame = CreateFrame("Frame", name, parent) end
	frame:Size(parent:GetWidth()-20, 1000)

	-- Create aura list
	RefreshAuraList(frame, name, config)

	-- Add button
	local addButton = B:CreateButton(parent, name.."_ADDBUTTON", "ADD", 80, 25, AddAuraHandler)
	addButton:ClearAllPoints()
	addButton:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, -2) -- attach to config panel
	addButton:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
	addButton:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
	addButton:Show()

	addButton.config = config
	addButton.name = name
	addButton.frame = frame

	-- Create edit panel (hidden by default) + apply button + cancel button
	local editPanelName = name.."_EDITPANEL_"
	local editPanel = _G[editPanelName]
	if not editPanel then
		editPanel = CreateFrame("Frame", editPanelName, frame)
		editPanel:SetTemplate()
		editPanel:Size(340, 100)
		editPanel:SetScript("OnShow", function(self) addButton:Hide() end)
		editPanel:SetScript("OnHide", function(self) addButton:Show() end)
	end
	editPanel:ClearAllPoints()
	editPanel:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -25, 0)
	-- spellID  label + editbox
	editPanel.spellIDLabel = B:CreateLabel(editPanel, name.."_EDITPANEL_SPELLIDLABEL", "Spell ID", 60, 25)
	editPanel.spellIDLabel:ClearAllPoints()
	editPanel.spellIDLabel:SetPoint("TOPLEFT", editPanel, "TOPLEFT", 4, -4)
	editPanel.spellIDEditbox = B:CreateEditbox(editPanel, name.."_EDITPANEL_SPELLIDEDITBOX", 100, 25, EditSpellIDHandler)
	editPanel.spellIDEditbox:ClearAllPoints()
	editPanel.spellIDEditbox:SetPoint("TOPLEFT", editPanel.spellIDLabel, "TOPRIGHT", 2, -2)
	-- icon
	local iconFrameName = name.."_EDITPANEL_ICONFRAME"
	editPanel.iconFrame = _G[iconFrameName]
	if not editPanel.iconFrame then
		editPanel.iconFrame = CreateFrame("Frame", iconFrameName, editPanel)
		editPanel.iconFrame:SetTemplate()
		editPanel.iconFrame:Size(50, 50)
		editPanel.iconFrame.icon = editPanel.iconFrame:CreateTexture(iconFrameName.."_ICON", "ARTWORK")
		editPanel.iconFrame.icon:SetPoint("TOPLEFT", 2, -2)
		editPanel.iconFrame.icon:SetPoint("BOTTOMRIGHT", -2, 2)
		editPanel.iconFrame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		-- set tooltip
		editPanel.iconFrame:SetScript("OnEnter", function(self)
			if not self:GetParent().spellID or self:GetParent().spellID == "" then return end
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 7)
			GameTooltip:SetHyperlink(format("spell:%s", self:GetParent().spellID))
			GameTooltip:Show()
		end)
		editPanel.iconFrame:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
	editPanel.iconFrame:ClearAllPoints()
	editPanel.iconFrame:SetPoint("TOPLEFT", editPanel.spellIDLabel, "BOTTOMLEFT", 0, -10)
	-- spellName  label
	editPanel.spellName = B:CreateLabel(editPanel, name.."_EDITPANEL_SPELLNAME", "", 200, 25)
	editPanel.spellName:SetFont(C.media.font, 14)
	editPanel.spellName:ClearAllPoints()
	editPanel.spellName:SetPoint("TOPLEFT", editPanel.iconFrame, "TOPRIGHT", 2, -2)
	-- apply button
	editPanel.applyButton = B:CreateButton(editPanel, name.."_EDITPANEL_APPLYBUTTON", "APPLY", 80, 25, EditAuraApplyHandler)
	editPanel.applyButton:ClearAllPoints()
	editPanel.applyButton:SetPoint("TOPLEFT", editPanel, "BOTTOMLEFT", 0, -2)
	editPanel.applyButton:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
	editPanel.applyButton:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
	editPanel.applyButton.config = config
	editPanel.applyButton.name = name
	editPanel.applyButton.frame = frame
	-- cancel button
	editPanel.cancelButton = B:CreateButton(editPanel, name.."_EDITPANEL_CANCELBUTTON", "CANCEL", 80, 25, EditAuraCancelHandler)
	editPanel.cancelButton:ClearAllPoints()
	editPanel.cancelButton:SetPoint("TOPRIGHT", editPanel, "BOTTOMRIGHT", 0, -2)
	editPanel.cancelButton:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
	editPanel.cancelButton:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
	-- hidden by default
	editPanel:Hide()

	frame.editPanel = editPanel

	frame:SetScript("OnShow", function(self) addButton:Show() end)
	frame:SetScript("OnHide", function(self) addButton:Hide() end)

	return frame
end

--------------

--[[
	LEVEL1							  LEVEL2
	[General Config ] --------------
	[Colors			]|				|
					 |				|
	[Spec1			]|				|[Spec Config] (linked to spec)
	[Spec2			]|				|[  SpellList] (linked to spec)
	[Spec3			]|				|
	[Spec4			]|				|
					 |				|
	[Buff			]|				|
	[Debuff			]|				|[  Blacklist] (linked to debuff)
	[Shields		]|				|[NoHighlight] (linked to debuff)
					  ---------------
--]]

-- Center
local ConfigFrame
local ConfigScrollArea
-- LEVEL1
local GeneralTab
local GeneralFrame
local ColorTab
local ColorFrame
local SpecTabs -- table
local BuffTab
local DebuffTab
local ShieldTab
-- LEVEL2
local SpecConfigTab -- linked to SpecTabs
local SpecFrame
local SpellListTab -- linked to SpecTabs
local SpellListFrames = {} -- table linked to SpecTabs
local BlacklistTab -- linked to DebuffTab
local BlacklistFrame -- linked to Debufftab
local NoHighlightTab -- linked to DebuffTab
local NoHighlightFrame -- linked to DebuffTab

-- Tabs management
local SelectedTabs = {}
local function SelectTab(tabGroup, tab)
	local selectedTab = SelectedTabs[tabGroup]
	if selectedTab == tab then return end -- nothing to do if selecting same tab
	if selectedTab then
		selectedTab:SetBackdropColor(unpack(C["media"].backdropcolor))
		if selectedTab.title then
			selectedTab.title:SetTextColor(1, 1, 1)
		end
		if selectedTab.onUnselect then
			selectedTab.onUnselect(selectedTab)
		end
	end
	-- recolor tab
	tab:SetBackdropColor(unpack(selectColor))
	if tab.title then
		tab.title:SetTextColor(0, 0, 0)
	end
	if tab.onSelect then
		tab.onSelect(tab)
	end
	SelectedTabs[tabGroup] = tab
end

local function UnselectTab(tabGroup)
	local selectedTab = SelectedTabs[tabGroup]
	if selectedTab then
		selectedTab:SetBackdropColor(unpack(C["media"].backdropcolor))
		if selectedTab.title then
			selectedTab.title:SetTextColor(1, 1, 1)
		end
		if selectedTab.onUnselect then
			selectedTab.onUnselect(selectedTab)
		end
	end
	SelectedTabs[tabGroup] = nil
end

-- Generic method to create tab
local function CreateTab(parent, group, name, width, height, anchor, title, onSelect, onUnselect)
	local frame = _G[name]
	if not frame then
		frame = CreateFrame("Button", name, parent)
		frame:SetTemplate("Transparent")
		frame:SetFrameStrata("DIALOG")
		frame:RegisterForClicks("LeftButtonUp")
		frame:Size(width, height)
		frame:SetPoint(unpack(anchor))
		-- title
		frame.title = frame:CreateFontString(nil, "OVERLAY")
		frame.title:SetPoint("CENTER", frame, 0, 0)
		frame.title:SetFont(C["media"].uffont, 14)
		frame.title:SetText(title) -- TODO: locales
		-- hover
		frame:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(hoverColor)) end)
		frame:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(C.media.bordercolor)) end)
		-- click
		frame:SetScript("OnClick", function(self) SelectTab(group, self) end)
		-- onSelect/onUnselect
		frame.onSelect = onSelect
		frame.onUnselect = onUnselect
		-- TODO: store tab in tabgroup list ?
	end
	return frame
end

---------------- level2
-- Spec config tab/frame
local function OnSpecConfigTabSelected(self)
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end
	if NoHighlightFrame then NoHighlightFrame:Hide() end

	-- TODO: create spec options
	SpecFrame = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumSpecFrame", SpecOptionsDefinition, SpecOptions)
	SpecFrame:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	SpecFrame:Show()

	ConfigScrollArea:SetScrollChild(SpecFrame)
	ConfigScrollArea:Show()
end

-- Spell list tab/frame
local function OnSpellListTabSelected(self)
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	if SpecFrame then SpecFrame:Hide() end
	if BlacklistFrame then BlacklistFrame:Hide() end
	if NoHighlightFrame then NoHighlightFrame:Hide() end

	-- if CurrentlySelectedSpecConfiguration == 1 then
		-- SpellListFrames[CurrentlySelectedSpecConfiguration] = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumSpellListFrame"..CurrentlySelectedSpecConfiguration, SpellListOptionsDefinition, SpellListOptions_1)
	-- else
		-- SpellListFrames[CurrentlySelectedSpecConfiguration] = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumSpellListFrame"..CurrentlySelectedSpecConfiguration, SpellListOptionsDefinition, SpellListOptions_2)
	-- end
	if not ns.SpellLists[T.myclass] then ns.SpellLists[T.myclass] = {} end
	if not ns.SpellLists[T.myclass][CurrentlySelectedSpecConfiguration] then ns.SpellLists[T.myclass][CurrentlySelectedSpecConfiguration] = {} end 
	if not ns.SpellLists[T.myclass][CurrentlySelectedSpecConfiguration].spells then ns.SpellLists[T.myclass][CurrentlySelectedSpecConfiguration].spells = {} end
	SpellListFrames[CurrentlySelectedSpecConfiguration] = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumSpellListFrame"..CurrentlySelectedSpecConfiguration, SpellListOptionsDefinition, ns.SpellLists[T.myclass][CurrentlySelectedSpecConfiguration].spells)
	SpellListFrames[CurrentlySelectedSpecConfiguration]:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	SpellListFrames[CurrentlySelectedSpecConfiguration]:Show()

	ConfigScrollArea:SetScrollChild(SpellListFrames[CurrentlySelectedSpecConfiguration])
	ConfigScrollArea:Show()
end

-- Black list tab/frame
local function OnBlacklistTabSelected(self)
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	if SpecFrame then SpecFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if NoHighlightFrame then NoHighlightFrame:Hide() end

	BlacklistFrame = CreateAuraPanel(ConfigFrame, "TukuiHealiumBlacklistFrame", BlacklistOptions)
	BlacklistFrame:Show()

	ConfigScrollArea:SetScrollChild(BlacklistFrame)
	ConfigScrollArea:Show()
end

-- No Highlight tab/frame
local function OnNoHighlightTabSelected(self)
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	if SpecFrame then SpecFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end

	NoHighlightFrame = CreateAuraPanel(ConfigFrame, "TukuiHealiumNoHighlightFrame", NoHighlightListOptions)
	NoHighlightFrame:Show()

	ConfigScrollArea:SetScrollChild(NoHighlightFrame)
	ConfigScrollArea:Show()
end

---------------- level1

-- General tab/frame
local function OnGeneralTabSelected(self)
	-- Unselect level2 tab and hide level2 tabs
	UnselectTab("LEVEL2")
	if SpecConfigTab then SpecConfigTab:Hide() end
	if SpellListTab then SpellListTab:Hide() end
	if BlacklistTab then BlacklistTab:Hide() end
	if NoHighlightTab then NoHighlightTab:Hide() end
	-- Hide config frames
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if SpecFrame then SpecFrame:Hide() end
	if BlacklistFrame then BlacklistFrame:Hide() end

	GeneralFrame = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumGeneralFrame", GeneralOptionsDefinition, GeneralOptions)
	GeneralFrame:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	GeneralFrame:Show()

	ConfigScrollArea:SetScrollChild(GeneralFrame)
	ConfigScrollArea:Show()
end

-- Color tab/frame
local function OnColorTabSelected(self)
	-- Unselect level2 tab and hide level2 tabs
	UnselectTab("LEVEL2")
	if SpecConfigTab then SpecConfigTab:Hide() end
	if SpellListTab then SpellListTab:Hide() end
	if BlacklistTab then BlacklistTab:Hide() end
	if NoHighlightTab then NoHighlightTab:Hide() end
	-- Hide config frames
	if GeneralFrame then GeneralFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if SpecFrame then SpecFrame:Hide() end
	if BlacklistFrame then BlacklistFrame:Hide() end

	ColorFrame = B:CreateOptionPanel(ConfigFrame, "TukuiHealiumColorFrame", ColorOptionsDefinition, ColorOptions)
	ColorFrame:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 10, 40)
	ColorFrame:Show()

	ConfigScrollArea:SetScrollChild(ColorFrame)
	ConfigScrollArea:Show()
end

-- Spec tab/frame
local function OnSpecTabSelected(self)
	-- Unselect level2
	UnselectTab("LEVEL2")
	-- Show spec level2 tab
	if SpecConfigTab then SpecConfigTab:Show() end
	if SpellListTab then SpellListTab:Show() end
	-- Hide remaining level2 tab
	if BlacklistTab then BlacklistTab:Hide() end
	if NoHighlightTab then NoHighlightTab:Hide() end
	-- Hide config frames
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end

	-- Select spec config tab
	SelectTab("LEVEL2", SpecConfigTab)

	-- TODO
	CurrentlySelectedSpecConfiguration = self.specIndex
end

-- Buff tab/frame
local function OnBuffTabSelected(self)
	-- Unselect level2 tab and hide level2 tabs
	UnselectTab("LEVEL2")
	if SpecConfigTab then SpecConfigTab:Hide() end
	if SpellListTab then SpellListTab:Hide() end
	if BlacklistTab then BlacklistTab:Hide() end
	if NoHighlightTab then NoHighlightTab:Hide() end
	-- Hide config frames
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end

	-- TODO
end

-- Debuff tab/frame
local function OnDebuffTabSelected(self)
	-- Unselect level2 tab
	UnselectTab("LEVEL2")
	if BlacklistTab then BlacklistTab:Show() end
	if NoHighlightTab then NoHighlightTab:Show() end
	-- Hide remaining level2 tab
	if SpecConfigTab then SpecConfigTab:Hide() end
	if SpellListTab then SpellListTab:Hide() end
	-- Hide config frames
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end

	-- Select blacklist tab
	SelectTab("LEVEL2", BlacklistTab)
	-- TODO
end

-- Shield tab/frame
local function OnShieldTabSelected(self)
	-- Unselect level2 tab and hide level2 tabs
	UnselectTab("LEVEL2")
	if SpecConfigTab then SpecConfigTab:Hide() end
	if SpellListTab then SpellListTab:Hide() end
	if BlacklistTab then BlacklistTab:Hide() end
	if NoHighlightTab then NoHighlightTab:Hide() end
	-- Hide config frames
	if GeneralFrame then GeneralFrame:Hide() end
	if ColorFrame then ColorFrame:Hide() end
	for k, SpellListFrame in pairs(SpellListFrames) do
		if SpellListFrame then SpellListFrame:Hide() end
	end
	if BlacklistFrame then BlacklistFrame:Hide() end

	-- TODO
end

local function CreateAllFrames() -- config frame + level1 tabs
	---------------------------
	-- Main frame
	if not ConfigFrame then
		ConfigFrame = CreateFrame("Frame", "TukuiHealiumConfigFrame", TukuiPetBattleHider)
		ConfigFrame:SetTemplate("Transparent")
		ConfigFrame:SetFrameStrata("DIALOG")
		ConfigFrame:Size(600, 400)
		ConfigFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		ConfigFrame:EnableMouse(true)
		ConfigFrame:SetMovable(true)
		ConfigFrame:RegisterForDrag("LeftButton")
		ConfigFrame:SetScript("OnDragStart", function(self) self:SetUserPlaced(true) self:StartMoving() end)
		ConfigFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		ConfigFrame:Hide() -- starts hidden
		-- title
		ConfigFrame.title = ConfigFrame:CreateFontString(nil, "OVERLAY")
		ConfigFrame.title:SetPoint("TOP", ConfigFrame, 0, -10)
		ConfigFrame.title:SetFont(C["media"].uffont, 14)
		ConfigFrame.title:SetText("|cffC495DDTukui|r Healium Configuration") -- TODO: locales
		-- close button
		local CloseButton = CreateFrame("Button", "TukuiHealiumConfigFrameCloseButton", ConfigFrame, "UIPanelCloseButton")
		CloseButton:SetPoint("TOPRIGHT", ConfigFrame, "TOPRIGHT")
		CloseButton:SkinCloseButton()
		CloseButton:SetScript("OnClick", function()
			UnselectTab("LEVEL1")
			UnselectTab("LEVEL2")
			ConfigFrame:Hide()
		end)
		-- scroll area
		ConfigScrollArea = CreateFrame("ScrollFrame", "TukuiHealiumConfigScrollArea", ConfigFrame, "UIPanelScrollFrameTemplate")
		ConfigScrollArea:SetPoint("TOPLEFT", ConfigFrame, "TOPLEFT", 8, -30)
		ConfigScrollArea:SetPoint("BOTTOMRIGHT", ConfigFrame, "BOTTOMRIGHT", -30, 8)
		_G[ConfigScrollArea:GetName().."ScrollBar"]:SkinScrollBar() -- Grrrrrrrrr
		ConfigScrollArea:Hide()
	end

	---------------------------
	-- level1
	---------------------------
	-- General tab
	GeneralTab = CreateTab(
		ConfigFrame,
		"LEVEL1",
		"TukuiHealiumGeneralTab",
		100,
		30,
		{"TOPRIGHT", ConfigFrame, "TOPLEFT", -4, 0},
		"General Config", -- TODO: locales
		OnGeneralTabSelected,
		nil)
	GeneralTab:Show()

	---------------------------
	-- Colors
	ColorTab = CreateTab(
		ConfigFrame,
		"LEVEL1",
		"TukuiHealiumColorTab",
		100,
		30,
		{"TOPRIGHT", GeneralTab, "BOTTOMRIGHT", 0, -4},
		"Colors", -- TODO: locales
		OnColorTabSelected,
		nil)

	---------------------------
	-- Spell list config
	local lastTab
	if not SpecTabs then
		SpecTabs = {}
		local numSpec = GetNumSpecializations()
		for i = 1, numSpec do
			local _, specName, _, specIcon = GetSpecializationInfo(i)
			local SpecTab = CreateTab(
				ConfigFrame,
				"LEVEL1",
				"TukuiHealiumSpecTab"..i,
				100,
				30,
				i == 1 and {"TOPRIGHT", ColorTab, "BOTTOMRIGHT", 0, -20} or {"TOPRIGHT", SpecTabs[i-1], "BOTTOMRIGHT", 0, -4},
				specName,
				OnSpecTabSelected,
				nil)
			-- misc
			SpecTab.specIndex = i -- save index
			-- icon
			SpecTab.icon = SpecTab:CreateTexture(nil, "OVERLAY")
			SpecTab.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			SpecTab.icon:SetPoint("TOPLEFT", 2, -2)
			SpecTab.icon:SetPoint("BOTTOMRIGHT", -72, 2) -- -72 = -100 + 30 - 2
			SpecTab.icon:SetTexture(specIcon)
			-- save tab
			SpecTabs[i] = SpecTab
			-- save last tab
			lastTab = SpecTab
		end
	end

	---------------------------
	-- Buffs
	BuffTab = CreateTab(
		ConfigFrame,
		"LEVEL1",
		"TukuiHealiumBuffTab",
		100,
		30,
		{"TOPRIGHT", lastTab, "BOTTOMRIGHT", 0, -20},
		"Buff", -- TODO: locales
		OnBuffTabSelected,
		nil)

	---------------------------
	-- Debuffs
	DebuffTab = CreateTab(
		ConfigFrame,
		"LEVEL1",
		"TukuiHealiumDebuffTab",
		100,
		30,
		{"TOPLEFT", BuffTab, "BOTTOMLEFT", 0, -4},
		"Debuff", -- TODO: locales
		OnDebuffTabSelected,
		nil)

	---------------------------
	-- Shields
	ShieldTab = CreateTab(
		ConfigFrame,
		"LEVEL1",
		"TukuiHealiumShieldTab",
		100,
		30,
		{"TOPLEFT", DebuffTab, "BOTTOMLEFT", 0, -4},
		"Shields", -- TODO: locales
		OnShieldTabSelected,
		nil)

	---------------------------
	-- level2
	---------------------------
	-- Spec general config
	SpecConfigTab = CreateTab(
		ConfigFrame, 
		"LEVEL2",
		"TukuiHealiumSpecConfigTab",
		100,
		30,
		{"TOPLEFT", ConfigFrame, "TOPRIGHT", 4, -70},
		"Spec Config", -- TODO: locales
		OnSpecConfigTabSelected,
		nil)

	---------------------------
	-- Spell List
	SpellListTab = CreateTab(
		ConfigFrame,
		"LEVEL2",
		"TukuiHealiumSpellListConfigTab",
		100,
		30,
		{"TOPLEFT", SpecConfigTab, "BOTTOMLEFT", 0, -4},
		"Spell List", -- TODO: locales
		OnSpellListTabSelected,
		nil)

	---------------------------
	-- Blacklist
	BlacklistTab = CreateTab(
		ConfigFrame,
		"LEVEL2",
		"TukuiHealiumBlacllistConfigTab",
		100,
		30,
		{"TOPLEFT", ConfigFrame, "TOPRIGHT", 4, -70},
		"Blacklist", -- TODO: locales
		OnBlacklistTabSelected,
		nil)

	---------------------------
	-- No Highlight
	NoHighlightTab = CreateTab(
		ConfigFrame,
		"LEVEL2",
		"TukuiHealiumNoHighlightConfigTab",
		100,
		30,
		{"TOPLEFT", BlacklistTab, "BOTTOMLEFT", 0, -4},
		"No Highlight", -- TODO: locales
		OnNoHighlightTabSelected,
		nil)
end

--
local function ToggleConfigFrame()
	if not ConfigFrame then
		CreateAllFrames()
	end
	if ConfigFrame:IsShown() then
		UnselectTab("LEVEL1")
		UnselectTab("LEVEL2")
		ConfigFrame:Hide()
	else
		ConfigFrame:Show()
		ConfigScrollArea:Hide()
		-- show level1 tabs
		GeneralTab:Show()
		ColorTab:Show()
		for _, tab in pairs(SpecTabs) do
			tab:Show()
		end
		BuffTab:Show()
		DebuffTab:Show()
		ShieldTab:Show()
		-- hide level2 tabs
		SpecConfigTab:Hide()
		SpellListTab:Hide()
		BlacklistTab:Hide()
		NoHighlightTab:Hide()
		---- Select general tab
		--SelectTab("LEVEL1", GeneralTab)
		--SelectTab("LEVEL1", SpecTabs[4])
		--SelectTab("LEVEL2", SpellListTab)
		SelectTab("LEVEL1", DebuffTab)
		SelectTab("LEVEL2", BlacklistTab)
	end
end

-- TEST
if not Tukui_TabMenu then
	print("CANNOT TEST OPTIONS WITHOUT TABMENU")
	return
end
local tab = Tukui_TabMenu:AddCustomTab(TukuiChatBackgroundRight, "LEFT", "TukuiHealiumOptions", "Interface/Icons/Spell_Holy_LayOnHands")
tab:SetScript("OnClick", ToggleConfigFrame)