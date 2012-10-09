local ADDON_NAME, ns = ...
local T = unpack(Tukui)
local L = ns.Locales

-- Nothing to do if TabMenu not loaded
if not IsAddOnLoaded("Tukui_TabMenu") then return end

-- Aliases
local Private = ns.Private

--local ToggleRaid = Private.ToggleRaid
local selectionColor = T.UnitColor.class[T.myclass]
local inTooltip = false

-- Functions
local function SetTabMenuColor(tab)
	-- set activation state
--print("SetTabMenuColor:"..tostring(db.show))
	if Private.IsEnabledForCurrentSpec() then
		tab.texture:SetVertexColor(unpack(selectionColor))
	else
		tab.texture:SetVertexColor(1, 1, 1)
	end
end

local function SetTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, T.Scale(6))
	GameTooltip:ClearAllPoints()
	GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, T.mult)
	GameTooltip:ClearLines()
	if Private.IsEnabledForCurrentSpec() then
		GameTooltip:AddDoubleLine(HIDE, "Tukui Healium raidframes", selectionColor[1], selectionColor[2], selectionColor[3], 1, 1, 1) -- TODO: locales
	else
		GameTooltip:AddDoubleLine(SHOW, "Tukui Healium raidframes", selectionColor[1], selectionColor[2], selectionColor[3], 1, 1, 1) -- TODO: locales
	end
	GameTooltip:Show()
end

local function OnEnter(self)
	inTooltip = true
	SetTooltip(self)
end

local function OnLeave(self)
	GameTooltip:Hide()
	inTooltip = false
end

local function OnClick(self)
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
end

-- Add tab menu
local tab = Tukui_TabMenu:AddCustomTab(TukuiChatBackgroundRight, "LEFT", "TukuiHealium", "Interface/Icons/Spell_Holy_LayOnHands")
tab:SetScript("OnEnter", OnEnter)
tab:SetScript("OnLeave", OnLeave)
tab:SetScript("OnClick", OnClick)
tab:Show()
-- Change tooltip/tab menu color when showing/hiding tukui healium
local function ShowHideRaidFrames(self)
	SetTabMenuColor(self)
	if inTooltip then
		SetTooltip(self)
	end
end
Private.RegisterCallback("HideRaidFrames", ShowHideRaidFrames, tab)
Private.RegisterCallback("ShowRaidFrames", ShowHideRaidFrames, tab)