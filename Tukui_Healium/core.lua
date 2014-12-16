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
--	[DONE]raid frames visibility per spec
--	[DONE]HealiumCore function to activate/deactivate events
--	[DONE]Toggle tab menu when using slash commands
--	[DONE]Cannot toggle/show/hide raid frame while in combat
--	[DONE]when starting addon, no need to initialize healium if show is false
--	[DONE]don't call ActivateSpellListForCurrentSpec if already activated and spell list has not been modified <-- PLAYER_ENTERING_WORLD and RaidFramesShown call it twice
--	[DONE]when group members are out-of-range, heal buttons backdrop is modified and correct (in-range is incorrect)
--	global enable/disable
--	BUG: delayed call to initialize+... when gaining a level
--	MacroChangedSpec: detect if macro has been modified

local ADDON_NAME, ns = ...

local oUF = TukuiUnitFrameFramework or oUF
assert(oUF, "Tukui_Healium was unable to locate oUF install.")

local T, C, _ = unpack(Tukui)
local H = unpack(HealiumCore)
local L = ns.Locales

-- Aliases
local Private = ns.Private
local Config = ns.Config
local SpellLists = ns.SpellLists
local TukuiUnitFrames = T.UnitFrames
local TukuiMovers = T.Movers
local TukuiPanels = T.Panels
local TukuiCooldowns = T.Cooldowns

local ERROR = Private.ERROR
local INFO = Private.INFO

local UnitWidth = 120
local UnitHeight = 28

-- Variables
--local delayedActivation = false -- spell list activation has been delayed because player was in combat
local TukuiHealiumInitialized = false
local CurrentSpellListNeedRefresh = true

-- Event handlers initialization
local EventsHandler = CreateFrame("Frame")
EventsHandler:RegisterEvent("PLAYER_ENTERING_WORLD") -- PLAYER_ENTERING_WORLD always trigger after ADDON LOADED (variables are loaded when PLAYER_ENTERING_WORLD trigger)
-- Set OnEvent handlers
EventsHandler:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

-- Greetings
local version = GetAddOnMetadata(ADDON_NAME, "Version")
local libVersion = GetAddOnMetadata("Healium_Core", "Version")
if libVersion then
	print(string.format(L.GREETING_VERSION, tostring(version), tostring(libVersion)))
else
	print(string.format(L.GREETING_VERSIONUNKNOWN, tostring(version)))
end

 -- Style function
 local function Shared(self, unit)
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.menu = T.SpawnMenu

	self:SetBackdrop({bgFile = C.Medias.blank, insets = {top = -T.Mult, left = -T.Mult, bottom = -T.Mult, right = -T.Mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(UnitHeight-1)
	health:SetStatusBarTexture(C.Medias.normTex)
	self.Health = health

	health.Background = health:CreateTexture(nil, 'BORDER')
	health.Background:SetAllPoints(health)
	health.Background:SetTexture(C.Medias.normTex)
	health.Background:SetTexture(0.3, 0.3, 0.3)
	health.Background.multiplier = 0.3
	self.Health.bg = health.Background

	health.Value = health:CreateFontString(nil, "OVERLAY")
	health.Value:SetPoint("RIGHT", health, -3, 1)
	health.Value:SetFont(C.Medias.Font, 12, "THINOUTLINE")
	health.Value:SetTextColor(1,1,1)
	health.Value:SetShadowOffset(1, -1)
	self.Health.Value = health.Value

	health.PostUpdate = TukuiUnitFrames.PostUpdateHealth

	health.frequentUpdates = true

	if C.UnitFrames.DarkTheme then
		health.colorTapping = false
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
		health.Background:SetVertexColor(0, 0, 0, 1)
	else
		health.colorTapping = true
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true
	end

	local power = CreateFrame("StatusBar", nil, self)
	power:Height(4)
	power:Point("TOPLEFT", health, "BOTTOMLEFT", 0, -1)
	power:Point("TOPRIGHT", health, "BOTTOMRIGHT", 0, -1)
	power:SetStatusBarTexture(C.Medias.normTex)
	self.Power = power

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.Background = self.Power:CreateTexture(nil, "BORDER")
	power.Background:SetAllPoints(power)
	power.Background:SetTexture(C.Medias.normTex)
	power.Background:SetAlpha(1)
	power.Background.multiplier = 0.4
	self.Power.bg = power.Background

	if C.UnitFrames.DarkTheme then
		power.colorTapping = true
		power.colorClass = true
		power.colorClassNPC = true
		power.colorClassPet = true
		power.Background.multiplier = 0.1
	else
		power.colorPower = true
	end

	local name = health:CreateFontString(nil, "OVERLAY")
	name:SetPoint("LEFT", health, 3, 0)
	name:SetFont(C.Medias.Font, 12, "THINOUTLINE")
	name:SetShadowOffset(1, -1)
	self:Tag(name, "[Tukui:NameShort]")
	self.Name = name

	local leader = health:CreateTexture(nil, "OVERLAY")
	leader:Height(12)
	leader:Width(12)
	leader:SetPoint("TOPLEFT", 0, 6)
	self.Leader = leader

	local LFDRole = health:CreateTexture(nil, "OVERLAY")
	LFDRole:Height(6)
	LFDRole:Width(6)
	LFDRole:Point("TOPRIGHT", -2, -2)
	LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	self.LFDRole = LFDRole

	local masterLooter = health:CreateTexture(nil, "OVERLAY")
	masterLooter:Height(12)
	masterLooter:Width(12)
	masterLooter:SetPoint("TOPLEFT", 2, 8)
	self.MasterLooter = masterLooter

	local threat = self.Health:CreateTexture(nil, "OVERLAY")
	threat.Override = TukuiUnitFrames.UpdateThreat
	self.Threat = threat

	local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
	RaidIcon:Height(18)
	RaidIcon:Width(18)
	RaidIcon:SetPoint('CENTER', self, 'TOP')
	RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
	self.RaidIcon = RaidIcon

	local ReadyCheck = self.Power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12)
	ReadyCheck:Width(12)
	ReadyCheck:SetPoint('CENTER')
	self.ReadyCheck = ReadyCheck

	local range = {insideAlpha = 1, outsideAlpha = C.Raid.RangeAlpha}
	self.Range = range

	if C.UnitFrames.Smooth == true then
		health.Smooth = true
		power.Smooth = true
	end

	if (C.UnitFrames.HealBar) then
		-- local FirstBar = CreateFrame("StatusBar", nil, self.Health)
		-- local SecondBar = CreateFrame("StatusBar", nil, self.Health)
		-- local ThirdBar = CreateFrame("StatusBar", nil, self.Health)

		-- FirstBar:Width(100)
		-- FirstBar:Height(UnitHeight-1)
		-- FirstBar:SetStatusBarTexture(C.Medias.normTex)
		-- FirstBar:SetStatusBarColor(0, 0.3, 0.15, 1)
		-- FirstBar:SetMinMaxValues(0,1)

		-- SecondBar:Width(100)
		-- SecondBar:Height(UnitHeight-1)
		-- SecondBar:SetStatusBarTexture(C.Medias.normTex)
		-- SecondBar:SetStatusBarColor(0, 0.3, 0, 1)

		-- ThirdBar:Width(100)
		-- ThirdBar:Height(UnitHeight-1)
		-- ThirdBar:SetStatusBarTexture(C.Medias.normTex)
		-- ThirdBar:SetStatusBarColor(0.3, 0.3, 0, 1)

		-- FirstBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		-- SecondBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		-- ThirdBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)

		-- SecondBar:SetFrameLevel(ThirdBar:GetFrameLevel() + 1)

		-- FirstBar:SetFrameLevel(ThirdBar:GetFrameLevel() + 2)

		-- self.HealPrediction = {
			-- myBar = FirstBar,
			-- otherBar = SecondBar,
			-- absBar = ThirdBar,
			-- maxOverflow = 1,
			-- healium = true,
		-- }

		------------------
		-- local FirstBar = CreateFrame("StatusBar", nil, self.Health)
		-- local SecondBar = CreateFrame("StatusBar", nil, self.Health)
		-- local ThirdBar = CreateFrame("StatusBar", nil, self.Health)
		
		-- FirstBar:Width(UnitWidth)
		-- --FirstBar:Height(UnitHeight-1)
		-- FirstBar:SetStatusBarTexture(C.Medias.Normal)
		-- FirstBar:SetStatusBarColor(0, 0.3, 0.15, 1)
		-- FirstBar:SetMinMaxValues(0,1)

		-- SecondBar:Width(UnitWidth)
		-- --SecondBar:Height(UnitHeight-1)
		-- SecondBar:SetStatusBarTexture(C.Medias.Normal)
		-- SecondBar:SetStatusBarColor(0, 0.3, 0, 1)

		-- ThirdBar:Width(UnitWidth)
		-- --ThirdBar:Height(UnitHeight-1)
		-- ThirdBar:SetStatusBarTexture(C.Medias.Normal)
		-- ThirdBar:SetStatusBarColor(0.3, 0.3, 0, 1)

		-- FirstBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		-- SecondBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)
		-- ThirdBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT", 0, 0)

		-- ThirdBar:SetFrameLevel(self.Health:GetFrameLevel() - 2)
		-- SecondBar:SetFrameLevel(ThirdBar:GetFrameLevel() + 1)
		-- FirstBar:SetFrameLevel(ThirdBar:GetFrameLevel() + 2)

		-- self.HealPrediction = {
			-- myBar = FirstBar,
			-- otherBar = SecondBar,
			-- absBar = ThirdBar,
			-- maxOverflow = 1,
		-- }

		--------------------
		local mhpb = CreateFrame('StatusBar', nil, health)
		mhpb:SetPoint('TOPLEFT', health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		mhpb:SetPoint('BOTTOMLEFT', health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		mhpb:SetWidth(150)
		mhpb:SetStatusBarTexture(C.Medias.normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)
		mhpb:SetMinMaxValues(0, 1)

		local ohpb = CreateFrame('StatusBar', nil, health)
		ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
		ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
		ohpb:SetWidth(150)
		ohpb:SetStatusBarTexture(C.Medias.normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}

		print("HEAL PREDICTION:"..(self.HealPrediction and "OK" or "x"))
	end

	H:RegisterFrame(self, "TukuiHealiumNormal")

	return self
 end

local function Initialize()
	if TukuiHealiumInitialized == true then return end 
	TukuiHealiumInitialized = true

	 -- Initialize Healium
	H:Initialize(Config)

	-- Register spell lists in Healium
	if SpellLists[T.MyClass] then
		for specIndex, specSetting in pairs(SpellLists[T.MyClass]) do
			if specIndex ~= "predefined" then
				local name = (type(specIndex) == "number") and (select(2, GetSpecializationInfo(specIndex))) or specIndex
				--H:RegisterSpellList(specIndex, specSetting.spells, specSetting.buffs)
				H:RegisterSpellList(name, specSetting.spells, specSetting.buffs)
			end
		end
	end

	--EventsHandler:RegisterEvent("PLAYER_REGEN_ENABLED")

	-- Create own raid header
	oUF:RegisterStyle('TukuiHealiumR01R25', Shared)
	oUF:Factory(function(self)
		oUF:SetActiveStyle("TukuiHealiumR01R25")

		local raid = oUF:SpawnHeader("TukuiHealiumRaid25Header", nil, "custom [@raid26,exists][vehicleui][petbattle][overridebar] hide;show", 
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(UnitWidth),
			'initial-height', T.Scale(UnitHeight),
			"showSolo", true, --C["unitframes"].showsolo,
			"showParty", true,
			"showPlayer", true, --C["unitframes"].showplayerinparty,
			"showRaid", true,
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"yOffset", T.Scale(-2))
		--RegisterStateDriver(raid, "visibility", "[vehicleui][petbattle][overridebar] hide; show")
		raid:SetParent(UIParent)
		--raid:SetTemplate()
		raid:Point("TOPLEFT", UIParent, "TOPLEFT", 80, -20)

		TukuiMovers:RegisterFrame(raid) -- Add mover

 -- TODO: pets

		---- Max number of group according to Instance max players (ripped from Tukui)
		local ten = "1,2"
		local twentyfive = "1,2,3,4,5"
		local forty = "1,2,3,4,5,6,7,8"

		local MaxGroup = CreateFrame("Frame", "TukuiHealiumRaidMaxGroup")
		MaxGroup:RegisterEvent("PLAYER_ENTERING_WORLD")
		MaxGroup:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		MaxGroup:SetScript("OnEvent", function(self)
			local filter
			local inInstance, instanceType = IsInInstance()
			--local _, _, _, _, maxPlayers, _, _ = GetInstanceInfo()
			local maxPlayers = select(5, GetInstanceInfo())
			
			if maxPlayers == 25 then
				filter = twentyfive
			elseif maxPlayers == 10 then
				filter = ten
			else
				filter = forty
			end

			if inInstance and instanceType == "raid" then
				raid:SetAttribute("groupFilter", filter)
				--if C.unitframes.showraidpets then
				 --TukuiRaidPet:SetAttribute("groupFilter", filter)
				--end
			 else
				raid:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
				--if C.unitframes.showraidpets then
					--TukuiRaidPet:SetAttribute("groupFilter", "1,2,3,4,5,6,7,8")
				--end
			end
		end)
	end)
 end

-- Activate spell list for current spec
local function ActivateSpellListForCurrentSpec()
	if not CurrentSpellListNeedRefresh then return end -- No activation if already activated
	CurrentSpellListNeedRefresh = false -- current spell list up-to-date
	local spec = GetSpecialization()
	local name = spec and select(2, GetSpecializationInfo(spec))
	H:ActivateSpellList(name) -- if called with name == nil, current spell list will be empty
end

local function HandleSpecChanged()
	if Private.IsEnabledForCurrentSpec() then
--print("PLAYER_SPECIALIZATION_CHANGED")
		CurrentSpellListNeedRefresh = Private.SpellChangedCheck() -- force spell list activation
		Initialize() -- Initialize if not yet initialized
		ActivateSpellListForCurrentSpec()
		if not Private.IsTukuiHealiumShown() then
			Private.ShowTukuiHealium(true)
		end
	else
		Private.ChangeCurrentSpec()
		if Private.IsTukuiHealiumShown() then
			Private.HideTukuiHealium(true)
		end
	end
end

-- Events handler
function EventsHandler:PLAYER_ENTERING_WORLD()
--print("PLAYER_ENTERING_WORLD:"..tostring(Private.IsEnabledForCurrentSpec()))
	-- First method called when addon is started, everything starts from here
	EventsHandler:UnregisterEvent("PLAYER_ENTERING_WORLD") -- fire only once
	EventsHandler:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player")
	EventsHandler:RegisterEvent("UPDATE_MACROS")
--print("PLAYER_ENTERING_WORLD")
	-- if Private.IsEnabledForCurrentSpec() then
-- --print("PLAYER_ENTERING_WORLD")
		-- CurrentSpellListNeedRefresh = true -- force spell list activation
		-- Initialize() -- Initialize only when needed
		-- ActivateSpellListForCurrentSpec()
		-- Private.ShowTukuiHealium(true)
	-- else
 		-- Private.HideTukuiHealium(true)
	-- end
	HandleSpecChanged()
--print("PLAYER_ENTERING_WORLD:"..tostring(db.show))
end

function EventsHandler:PLAYER_SPECIALIZATION_CHANGED(arg1, arg2)
--print("PLAYER_SPECIALIZATION_CHANGED:"..tostring(Private.IsEnabledForCurrentSpec()).."  "..tostring(arg1).."  "..tostring(arg2))
	-- if InCombatLockdown() then
		-- --delayedActivation = true
		-- --ERROR(L.ERROR_NOTINCOMBAT)
		-- Private.DelayedAction(HandleSpecChanged)
	-- else
		-- HandleSpecChanged()
	-- end
	Private.DelayedAction(HandleSpecChanged)
end

function EventsHandler:UPDATE_MACROS()
--print("UPDATE_MACROS:"..tostring(Private.IsEnabledForCurrentSpec()))
	-- TODO: only if updated macro was in spell list
	if InCombatLockdown() then
		--delayedActivation = true
		ERROR(L.ERROR_NOTINCOMBAT)
	else
		if Private.IsEnabledForCurrentSpec() then
--print("UPDATE_MACROS")
			CurrentSpellListNeedRefresh = true -- force spell list activation
			Initialize() -- Initialize if not yet initialized
			ActivateSpellListForCurrentSpec()
		end
	end
end

local function RaidFramesShown()
--print("RaidFramesShown")
	Initialize() -- Initialize if not yet initialized
	ActivateSpellListForCurrentSpec()
end
Private.RegisterCallback("ShowRaidFrames", RaidFramesShown)

-- function EventsHandler:PLAYER_REGEN_ENABLED()
	-- if InCombatLockdown() then return end -- SHOULD NEVER HAPPEN
	-- if delayedActivation then
		-- ActivateSpellListForCurrentSpec()
		-- delayedActivation = false
	-- end
-- end