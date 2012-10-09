local ADDON_NAME, ns = ...
local T, C, _ = unpack(Tukui)

-- Only if Tukui_TabMenu not found
if IsAddOnLoaded("Tukui_TabMenu") then return end

-- Aliases
local Private = ns.Private
local L = ns.Locales

--
local button = CreateFrame("Button", "TukuiHealiumMiniMap", Minimap)
button:SetFrameStrata("MEDIUM")
button:EnableMouse(true)
button:RegisterForClicks("LeftButtonUp")
button:SetHeight(18)
button:SetWidth(18)
button:SetPoint( "TOPLEFT", "Minimap", "TOPLEFT", 62-(80*cos(5)), (80*sin(5))-62)
button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")

local overlay = button:CreateTexture(nil, "OVERLAY")
overlay:SetWidth(53)
overlay:SetHeight(53)
overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
overlay:SetPoint("TOPLEFT")

local background = button:CreateTexture(nil, "BACKGROUND")
background:SetWidth(20)
background:SetHeight(20)
background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
background:SetPoint("TOPLEFT", 7, -5)

local icon = button:CreateTexture(nil, "ARTWORK")
icon:SetWidth(17)
icon:SetHeight(17)
icon:SetTexture("Interface/Icons/Spell_Holy_LayOnHands")
icon:SetPoint("TOPLEFT", 7, -6)
button.icon = icon

-- TODO: drag&drop

local inTooltip = false
local function SetTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	if Private.IsEnabledForCurrentSpec() then
		GameTooltip:SetText("Click to "..HIDE .. " Tukui Healium raidframes") -- TODO locales
	else
		GameTooltip:SetText("Click to "..SHOW .. " Tukui Healium raidframes") -- TODO locales
	end
	GameTooltip:Show()
end

button:SetScript("OnMouseDown", function(self)
	self.icon:Point("TOPLEFT", self, 4, -4)
	self.icon:Point("BOTTOMRIGHT", self, -4, 4)
end)

button:SetScript("OnMouseUp", function(self)
	self.icon:Point("TOPLEFT", self, 2, -2)
	self.icon:Point("BOTTOMRIGHT", self, -2, 2)
end)

button:SetScript("OnEnter", function(self)
	inTooltip = true
	SetTooltip(self)
end)

button:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
	inTooltip = false
end)

button:SetScript("OnClick", function(self)
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end
	if Private.IsEnabledForCurrentSpec() then
		Private.DisableForCurrentSpec()
		Private.HideTukuiHealium()
	else
		Private.EnableForCurrentSpec()
		Private.ShowTukuiHealium()
	end
end)

-- Change tooltip when showing/hiding tukui healium
local function ShowHideRaidFrames(self)
	if inTooltip then
		SetTooltip(self)
	end
end

Private.RegisterCallback("HideRaidFrames", ShowHideRaidFrames, button)
Private.RegisterCallback("ShowRaidFrames", ShowHideRaidFrames, button)