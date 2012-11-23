local ADDON_NAME, ns = ...
local T, C, _ = unpack(Tukui)

-- TODO: drag&drop

-- Only if Tukui_TabMenu not found
if IsAddOnLoaded("Tukui_TabMenu") then return end

-- Aliases
local Private = ns.Private
local L = ns.Locales

--
local button = CreateFrame("Button", "TukuiHealiumMiniMap", Minimap)
button:SetTemplate()
button:SetFrameStrata("MEDIUM")
button:EnableMouse(true)
button:RegisterForClicks("LeftButtonUp")
button:Size(24)
button:Point( "TOPLEFT", "Minimap", "TOPLEFT", 62-(80*cos(5)), (80*sin(5))-62)
button:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")

local icon = button:CreateTexture(nil, "ARTWORK")
icon:Size(24)
icon:SetTexture("Interface/Icons/Spell_Holy_LayOnHands")
icon:SetTexCoord(.08,.88,.08,.88)
icon:Point("TOPLEFT", button, 2, -2)
icon:Point("BOTTOMRIGHT", button, -2, 2)
button.icon = icon

local inTooltip = false
local function SetTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	if Private.IsEnabledForCurrentSpec() then
		GameTooltip:SetText("Click to hide Tukui Healium raidframes") -- TODO locales
	else
		GameTooltip:SetText("Click to show Tukui Healium raidframes") -- TODO locales
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