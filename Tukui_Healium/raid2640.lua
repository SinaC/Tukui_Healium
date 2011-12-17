local ADDON_NAME, ns = ...
if not ns.Enabled then return end

local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

local font2 = C["media"].uffont
local font1 = C["media"].font
local normTex = C["media"].normTex
local bdcr, bdcg, bdcb = unpack(C["media"].bordercolor)
local backdrop = {
	bgFile = C["media"].blank,
	insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult},
}
local point = "LEFT"
local columnAnchorPoint = "TOP"

local function Shared(self, unit)

	self.colors = T.UnitColor
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self.menu = T.SpawnMenu

	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	local health = CreateFrame("StatusBar", nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("TOPRIGHT")
	health:Height(27*T.raidscale)
	health:SetStatusBarTexture(normTex)
	self.Health = health

	health.bg = health:CreateTexture(nil, "BORDER")
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = 0.3
	self.Health.bg = health.bg

	-- health.valueFrame = CreateFrame("Frame", nil, health)
	-- health.valueFrame:SetAllPoints(health)
	-- health.valueFrame:SetWidth(50)
	-- health.valueFrame:SetFrameStrata("MEDIUM")
	-- health.valueFrame:SetFrameLevel(15)
	-- health.value = health.valueFrame:CreateFontString(nil, "OVERLAY")
	-- health.value:SetPoint("RIGHT", health.valueFrame, -3, 1)
	-- health.value:SetFont(font2, 12*T.raidscale, "THINOUTLINE")
	-- health.value:SetTextColor(1,1,1)
	-- health.value:SetShadowOffset(1, -1)
	-- self.Health.value = health.value

	--health.PostUpdate = T.PostUpdateHealthRaid

	health.frequentUpdates = true

	if C["unitframes"].unicolor == true then
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
	power:Width(3*T.raidscale)
	power:Height(27*T.raidscale)
	power:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	power:SetStatusBarTexture(normTex)
	power:SetOrientation("VERTICAL")
	--power:SetFrameLevel(9)
	self.Power = power

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = self.Power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	self.Power.bg = power.bg

	if C["unitframes"].unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1
	else
		power.colorPower = true
	end

	local name = health:CreateFontString(nil, "OVERLAY")
	name:SetPoint("LEFT", health, 3, 0)
	name:SetFont(font2, 12*T.raidscale, "THINOUTLINE")
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
	self.LFDRole.Override = LFDRoleUpdate

	local MasterLooter = health:CreateTexture(nil, "OVERLAY")
	MasterLooter:Height(12*T.raidscale)
	MasterLooter:Width(12*T.raidscale)
	self.MasterLooter = MasterLooter
	self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)

	if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", T.UpdateThreat)
		self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", T.UpdateThreat)
		self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", T.UpdateThreat)
	end

	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, "OVERLAY")
		RaidIcon:Height(18*T.raidscale)
		RaidIcon:Width(18*T.raidscale)
		RaidIcon:SetPoint("CENTER", self, "TOP")
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end

	local ReadyCheck = health:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*T.raidscale)
	ReadyCheck:Width(12*T.raidscale)
	ReadyCheck:SetPoint("CENTER", self, "BOTTOM")
	self.ReadyCheck = ReadyCheck

	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end

	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end

	if C["unitframes"].healcomm then
		local width = self:GetWidth()
		local mhpb = CreateFrame("StatusBar", nil, self.Health)
		mhpb:SetPoint("TOPLEFT", self.Health:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		mhpb:SetPoint("BOTTOMLEFT", self.Health:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		mhpb:SetWidth(width*T.raidscale)
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame("StatusBar", nil, self.Health)
		ohpb:SetPoint("TOPLEFT", mhpb:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
		ohpb:SetPoint("BOTTOMLEFT", mhpb:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
		ohpb:SetWidth(width*T.raidscale)
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end

--[[
	self.colors = T.UnitColor
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)

	self.menu = T.SpawnMenu

	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)

	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT", 3, 0)
	health:SetPoint("TOPRIGHT", 3, 0)
	health:Height(28*C["unitframes"].gridscale*T.raidscale)
	--health:Height(27*T.raidscale)
	health:SetStatusBarTexture(normTex)
	self.Health = health

	if C["unitframes"].gridhealthvertical == true then
		health:SetOrientation('VERTICAL')
	end

	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg

	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:Point("CENTER", health, 1, 0)
	health.value:SetFont(font2, 11*C["unitframes"].gridscale*T.raidscale, "THINOUTLINE")
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
	-- power:SetHeight(3*C["unitframes"].gridscale*T.raidscale)
	-- power:Point("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	-- power:Point("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
	--power:Width(3*C["unitframes"].gridscale**T.raidscale)
	--power:Height(27*C["unitframes"].gridscale**T.raidscale)
	power:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
	power:SetPoint("BOTTOMRIGHT", health, "BOTTOMLEFT", 0, 0)
	power:SetStatusBarTexture(normTex)
	-- power:SetOrientation("VERTICAL")
	self.Power = power

	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4

	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end
	
	-- local panel = CreateFrame("Frame", nil, self)
	-- panel:Point("TOPLEFT", power, "BOTTOMLEFT", 0, -1)
	-- panel:Point("TOPRIGHT", power, "BOTTOMRIGHT", 0, -1)
    -- panel:SetPoint("BOTTOM", 0,0)
	-- panel:SetBackdrop( {
        -- bgFile = C["media"].blank,
        -- edgeFile = C["media"].blank,
        -- tile = false, tileSize = 0, edgeSize = T.mult,
        -- insets = { left = 0, right = 0, top = 0, bottom = 0 }
    -- })
    -- panel:SetBackdropColor(unpack(C["media"].backdropcolor))
    -- panel:SetBackdropBorderColor(bdcr * 0.7, bdcg * 0.7, bdcb * 0.7)
	-- self.panel = panel

	--local name = panel:CreateFontString(nil, "OVERLAY")
	local name = health:CreateFontString(nil, "OVERLAY")
    -- name:SetPoint("TOP") 
	-- name:SetPoint("BOTTOM") 
	-- name:SetPoint("LEFT") 
	-- name:SetPoint("RIGHT")
	name:SetPoint("LEFT", health, 3, 0)
	name:SetFont(font2, 12*C["unitframes"].gridscale*T.raidscale)
	name:SetShadowOffset(1, -1)
	self:Tag(name, "[Tukui:getnamecolor][Tukui:nameshort]")
	self.Name = name
	
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
	
	local ReadyCheck = power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*C["unitframes"].gridscale*T.raidscale)
	ReadyCheck:Width(12*C["unitframes"].gridscale*T.raidscale)
	ReadyCheck:SetPoint('CENTER') 	
	self.ReadyCheck = ReadyCheck

	-- local leader = health:CreateTexture(nil, "OVERLAY")
	-- leader:Height(12*T.raidscale)
	-- leader:Width(12*T.raidscale)
	-- leader:SetPoint("TOPLEFT", 0, 6)
	-- self.Leader = leader

	-- local LFDRole = health:CreateTexture(nil, "OVERLAY")
	-- LFDRole:Height(6*T.raidscale)
	-- LFDRole:Width(6*T.raidscale)
	-- LFDRole:Point("TOPRIGHT", -2, -2)
	-- LFDRole:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\lfdicons.blp")
	-- self.LFDRole = LFDRole

	-- local MasterLooter = health:CreateTexture(nil, "OVERLAY")
	-- MasterLooter:Height(12*T.raidscale)
	-- MasterLooter:Width(12*T.raidscale)
	-- self.MasterLooter = MasterLooter
	-- self:RegisterEvent("PARTY_LEADER_CHANGED", T.MLAnchorUpdate)
	-- self:RegisterEvent("PARTY_MEMBERS_CHANGED", T.MLAnchorUpdate)

	self.DebuffHighlightAlpha = 1
	self.DebuffHighlightBackdrop = true
	self.DebuffHighlightFilter = true
	
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
		if C["unitframes"].gridhealthvertical then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:Width(66*C["unitframes"].gridscale*T.raidscale)
			mhpb:Height(50*C["unitframes"].gridscale*T.raidscale)		
		else
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:Width(66*C["unitframes"].gridscale*T.raidscale)
		end				
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if C["unitframes"].gridhealthvertical then
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:Width(66*C["unitframes"].gridscale*T.raidscale)
			ohpb:Height(50*C["unitframes"].gridscale*T.raidscale)
		else
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:Width(6*C["unitframes"].gridscale*T.raidscale)
		end
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
--]]

	H:RegisterFrame(self, "TukuiHealiumGrid")

	return self
end

oUF:RegisterStyle('TukuiHealR26R40', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiHealR26R40")

	if C.unitframes.gridvertical then
		point = "TOP"
		columnAnchorPoint = "LEFT"
	end
		
	if C["unitframes"].gridonly ~= true then
		local raid = self:SpawnHeader("TukuiRaidHealerGrid", nil, "custom [@raid26,exists] show;hide",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(100),
			'initial-height', T.Scale(67),
			"showSolo", C["unitframes"].showsolo,
			"showPlayer", C["unitframes"].showplayerinparty, 
			"showRaid", true,
			"xoffset", T.Scale(3),
			"yOffset", T.Scale(-3),
			"point", point,
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(3),
			"columnAnchorPoint", columnAnchorPoint	
		)
		raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 18, -250*T.raidscale)
	else
		local raid = self:SpawnHeader("TukuiRaidHealerGrid", nil, "solo,raid,party",
			'oUF-initialConfigFunction', [[
				local header = self:GetParent()
				self:SetWidth(header:GetAttribute('initial-width'))
				self:SetHeight(header:GetAttribute('initial-height'))
			]],
			'initial-width', T.Scale(100),
			'initial-height', T.Scale(67),
			"showParty", true,
			"showSolo", C["unitframes"].showsolo,
			"showPlayer", C["unitframes"].showplayerinparty, 
			"showRaid", true, 
			"xoffset", T.Scale(3),
			"yOffset", T.Scale(-3),
			"point", point,
			"groupFilter", "1,2,3,4,5,6,7,8",
			"groupingOrder", "1,2,3,4,5,6,7,8",
			"groupBy", "GROUP",
			"maxColumns", 8,
			"unitsPerColumn", 5,
			"columnSpacing", T.Scale(3),
			"columnAnchorPoint", columnAnchorPoint	
		)
		raid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 18, -250*T.raidscale)
	end
end)