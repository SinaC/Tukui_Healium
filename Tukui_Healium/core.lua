-- TODO:
--	[DONE]move spell list from HealiumCore
--	[DONE]call H:RegisterSpellList(specName | settingName, spellList, buffList) for each spell list in config
--	[DONE]call H:ActivateSpellList(specName | settingName) for current spec
--	[DONE]handle event spec_changed and call ActivateSpellList(specName | settingName)
--	add dropdown menu in a Tukui_TabMenu to switch easily from one setting to another, toggle raid frames visibility
--	[DONE]change TOC version to 2.0
--	[DONE]use spec name instead of spec id for register/activate
--	modify blacklist/whitelist/... from HealiumCore --> move filters from HealiumCore to Tukui_Healium
--	config window to create spell list
--	[DONE]slash command to toggle raid frames visibility
--	raid frames visibility per spec
--	HealiumCore function to activate/deactivate events
--	Toggle tab menu when using slash commands
--	Cannot toggle/show/hide raid frame while in combat
--	module for delayed function call while in combat

local ADDON_NAME, ns = ...

local oUF = oUFTukui or oUF
assert(oUF, "Tukui_Healium was unable to locate oUF install.")

local T, C, _ = unpack(Tukui)
local H = unpack(HealiumCore)
local L = ns.Locales

-- Aliases
local Private = ns.Private
local config = ns.config
local spellLists = ns.spellLists
local RegisterCallback = Private.RegisterCallback
local FireCallback = Private.FireCallback

local ShowTukuiHealium = Private.ShowTukuiHealium
local HideTukuiHealium = Private.HideTukuiHealium

-- Variables
local delayedActivation = false -- spell list activation has been delayed because player was in combat
local EventsHandler = CreateFrame("Frame")

-- Initialize Healium
H:Initialize(config)

-- Greetings
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local libVersion = GetAddOnMetadata("Healium_Core", "Version")
if libVersion then
	print(string.format(L.GREETING_VERSION, tostring(version), tostring(libVersion)))
else
	print(string.format(L.GREETING_VERSIONUNKNOWN, tostring(version)))
end

-- Initialize event handlers
EventsHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
-- Set OnEvent handlers
EventsHandler:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-- Avoid calling Tukui raid header (SpawnHeader)
--oUF:DisableFactory()

-- Style function
local function Shared(self, unit)
	self.colors = T.UnitColor
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.menu = T.SpawnMenu

	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(27*T.raidscale)
	health:SetStatusBarTexture(C["media"].normTex)
	self.Health = health

	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(C["media"].normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = 0.3
	self.Health.bg = health.bg

	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:SetPoint("RIGHT", health, -3, 1)
	health.value:SetFont(C["media"].uffont, 12*T.raidscale, "THINOUTLINE")
	health.value:SetTextColor(1,1,1)
	health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value

	health.PostUpdate = T.PostUpdateHealthRaid

	health.frequentUpdates = true

	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true
	end

	local power = CreateFrame("StatusBar", nil, self)
	power:Height(4*T.raidscale)
	power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
	power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
	power:SetStatusBarTexture(C["media"].normTex)
	self.Power = power

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(C["media"].normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	self.Power.bg = power.bg

	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1
	else
		power.colorPower = true
	end

	local name = health:CreateFontString(nil, "OVERLAY")
	name:SetPoint("LEFT", health, 3, 0)
	name:SetFont(C["media"].uffont, 12*T.raidscale, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	self:Tag(name, "[Tukui:namemedium]")
	self.Name = name

	local leader = health:CreateTexture(nil, "OVERLAY")
	leader:Height(12*T.raidscale)
	leader:Width(12*T.raidscale)
	leader:SetPoint("TOPLEFT", 0, 6)
	self.Leader = leader

	local LFDRole = health:CreateTexture(nil, "OVERLAY")
	LFDRole:Height(6*T.raidscale)
	LFDRole:Width(6*T.raidscale)
	LFDRole:Point("TOPRIGHT", -2, -2)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole

	local MasterLooter = health:CreateTexture(nil, "OVERLAY")
	MasterLooter:Height(12*T.raidscale)
	MasterLooter:Width(12*T.raidscale)
	self.MasterLooter = MasterLooter
	self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)

	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
	end

	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(18*T.raidscale)
		RaidIcon:Width(18*T.raidscale)
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end

	local ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck

	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = false

	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end

	if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		mhpb:SetWidth(150*T.raidscale)
		mhpb:SetStatusBarTexture(C["media"].normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetWidth(150*T.raidscale)
		ohpb:SetStatusBarTexture(C["media"].normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end

	H:RegisterFrame(self, "TukuiHealiumNormal")

	return self
end

-- Create own raid header
oUF:RegisterStyle('TukuiHealiumR01R25', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealiumR01R25")

	local raid = oUF:SpawnHeader("TukuiRaidHealer25", nil, "custom [@raid26,exists] hide;show", 
	'oUF-initialConfigFunction', [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute('initial-width'))
		self:SetHeight(header:GetAttribute('initial-height'))
	]],
	'initial-width', T.Scale(120*T.raidscale),
	'initial-height', T.Scale(28*T.raidscale),
	"showSolo", true, --C["unitframes"].showsolo,
	"showParty", true,
	"showPlayer", true, --C["unitframes"].showplayerinparty,
	"showRaid", true,
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", "GROUP",
	"yOffset",
	T.Scale(-4))
	raid:SetParent(TukuiPetBattleHider)
	raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 15, -300*T.raidscale)

	-- TODO: pets   TukuiRaidHealerPet15
end)

--TukuiRaid:Kill()
--TukuiRaidPet:Kill()

-- Activate spell list for current spec
local function ActivateSpellListForCurrentSpec()
	local spec = GetSpecialization()
	local name = spec and select(2, GetSpecializationInfo(spec))
	H:ActivateSpellList(name) -- if called with name == nil, current spell list will be empty
end

-- Events handler
function EventsHandler:PLAYER_ENTERING_WORLD()
	EventsHandler:UnregisterEvent("PLAYER_ENTERING_WORLD") -- fire only once

	if TukuiHealiumDataPerCharacter.show == true then
		ShowTukuiHealium(true)
	else
 		HideTukuiHealium(true)
	end
print("PLAYER_ENTERING_WORLD:"..tostring(TukuiHealiumDataPerCharacter.show))

	-- Register spell lists in Healium
	if spellLists[T.myclass] then
		for specIndex, specSetting in pairs(spellLists[T.myclass]) do
			if specIndex ~= "predefined" then
				local name = (type(specIndex) == "number") and (select(2, GetSpecializationInfo(specIndex))) or specIndex
--print(tostring(specIndex).."  "..type(specIndex).."  "..tostring(name))
				--H:RegisterSpellList(specIndex, specSetting.spells, specSetting.buffs)
				H:RegisterSpellList(name, specSetting.spells, specSetting.buffs)
			end
		end
	end

	EventsHandler:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	EventsHandler:RegisterEvent("UPDATE_MACROS")
	EventsHandler:RegisterEvent("PLAYER_REGEN_ENABLED")

	ActivateSpellListForCurrentSpec()
end

function EventsHandler:PLAYER_SPECIALIZATION_CHANGED(unit)
--print("PLAYER_SPECIALIZATION_CHANGED: "..tostring(unit))
	if unit ~= "player" then return end
	if InCombatLockdown() then
		delayedActivation = true
	else
		ActivateSpellListForCurrentSpec()
	end
end

function EventsHandler:UPDATE_MACROS()
	-- TODO: only if updated macro was in spell list
	if InCombatLockdown() then
		delayedActivation = true
	else
		ActivateSpellListForCurrentSpec()
	end
end

function EventsHandler:PLAYER_REGEN_ENABLED()
	if InCombatLockdown() then return end -- SHOULD NEVER HAPPEN
	if delayedActivation then
		ActivateSpellListForCurrentSpec()
		delayedActivation = false
	end
end