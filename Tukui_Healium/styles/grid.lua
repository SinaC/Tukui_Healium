
-- Grid healium
-------------------------------------------------------

local ADDON_NAME, ns = ...
--local SinaCUI = ns.SinaCUI
--if not SinaCUI.HealiumEnabled then return end

--local Private = SinaCUI.Private
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

-- only one debuff inside frame
-- x rows of y buttons below frame
-- buff inside frame
-- ______________
-- |     DD      |
-- | _BB_BB_BB_BB|
-- HH HH HH HH HH
-- HH HH HH HH HH
-- HH HH HH HH HH
-- BB: buff
-- DD: debuff
-- HH: button

local function SkinHealiumGridButton(frame, button)
	button:SetTemplate("Default")
	button:Size(C["raidhealium"].gridbuttonsize, C["raidhealium"].gridbuttonsize)
	--button:SetFrameStrata("BACKGROUND")
	button:SetFrameLevel(9)
	button:SetFrameStrata(frame:GetFrameStrata())
	button:SetBackdrop(nil)
	if button.texture then
		button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.texture:SetAllPoints(button)
		button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
		button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		button.texture:SetVertexColor(1, 1, 1)
	end
	-- button:SetBackdropColor(0, 0, 0)
	-- button:SetBackdropBorderColor(0, 0, 0)
end

local function SkinHealiumGridDebuff(frame, debuff)
	debuff:SetTemplate("Default")
	debuff:Size(C["raidhealium"].griddebuffsize, C["raidhealium"].griddebuffsize)
	--debuff:SetFrameStrata("BACKGROUND")
	debuff:SetFrameLevel(9)
	debuff:SetFrameStrata(frame:GetFrameStrata())
	if debuff.icon then
		debuff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		debuff.icon:ClearAllPoints()
		debuff.icon:Point("TOPLEFT", 1, -1)
		debuff.icon:Point("BOTTOMRIGHT", -1, 1)
	end
	if debuff.count then
		debuff.count:SetFont(C.Medias.Font, 14, "OUTLINE")
		debuff.count:ClearAllPoints()
		debuff.count:Point("BOTTOMRIGHT", 1, -1)
		debuff.count:SetJustifyH("CENTER")
	end
	if debuff.shield then
		debuff.shield:SetFont(C.Medias.Font, 12, "OUTLINE")
		debuff.shield:ClearAllPoints()
		debuff.shield:Point("TOPLEFT", 1, 1)
		debuff.shield:SetJustifyH("CENTER")
	end
	-- debuff:SetAlpha(0.1)
	-- debuff.icon:SetAlpha(0.1)

	-- if we set framelevel to 3 (parent.Health:GetFrameLevel()) and ARTWORK to OVERLAY --> player name and debuff cooldown/count are shown over debuff icon
end

local function SkinHealiumGridBuff(frame, buff)
	buff:SetTemplate("Default")
	buff:Size(C["raidhealium"].gridbuffsize, C["raidhealium"].gridbuffsize)
	--buff:SetFrameStrata("BACKGROUND")
	buff:SetFrameLevel(9)
	buff:SetFrameStrata(frame:GetFrameStrata())
	--buff:SetBackdrop(nil)
	if buff.icon then
		buff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		buff.icon:SetAllPoints(buff)
	end
	if buff.count then
		buff.count:SetFont(C.Medias.Font, 14, "OUTLINE")
		buff.count:ClearAllPoints()
		buff.count:Point("BOTTOMRIGHT", 1, -1)
		buff.count:SetJustifyH("CENTER")
	end
	if buff.shield then
		buff.shield:SetFont(C.Medias.Font, 12, "OUTLINE")
		buff.shield:ClearAllPoints()
		buff.shield:Point("TOPLEFT", 1, 1)
		buff.shield:SetJustifyH("CENTER")
	end
end

local function AnchorGridButton(frame, button, buttonList, index)
--print("AnchorGridButton:"..tostring(frame:GetName()).."  "..tostring(button).."  "..tostring(buttonList).."  "..tostring(index).."  "..tostring(frame.Health))
	-- Matrix-positioning
	local anchor
	if index == 1 then
		anchor = {"TOPLEFT", frame.Health, "BOTTOMLEFT", 0, 0}
	elseif (index % C["raidhealium"].gridbuttonbyrow) == 1 then
		anchor = {"TOPLEFT", buttonList[index-C["raidhealium"].gridbuttonbyrow], "BOTTOMLEFT", 0, --[[-Private.Healium_GridButtonSpacing--]]0}
	else
		anchor = {"TOPLEFT", buttonList[index-1], "TOPRIGHT", --[[Private.Healium_GridButtonSpacing--]]0, 0}
	end
--print("AnchorGridButton:anchoring")
	button:ClearAllPoints()
	button:Point(unpack(anchor))
end

local function AnchorGridDebuff(frame, debuff)
	-- Left-positioning
	local anchor = {"LEFT", frame.Health, "LEFT", 10, 0}
	debuff:ClearAllPoints()
	debuff:Point(unpack(anchor))
end

local function AnchorGridBuff(frame, buff, buffList, index)
	-- Line-positioning
	local anchor
	if index == 1 then
		anchor = {"BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -1, 1}
	else
		anchor = {"TOPRIGHT", buffList[index-1], "TOPLEFT", --[[-Private.Healium_GridBuffSpacing--]]0, 0}
	end
	buff:ClearAllPoints()
	buff:Point(unpack(anchor))
end

local HealiumGridStyle = {
	SkinButton = SkinHealiumGridButton,
	SkinDebuff = SkinHealiumGridDebuff,
	SkinBuff = SkinHealiumGridBuff,
	AnchorButton = AnchorGridButton,
	AnchorDebuff = AnchorGridDebuff,
	AnchorBuff = AnchorGridBuff,
	PriorityDebuff = true
}
H:RegisterStyle("TukuiHealiumGrid", HealiumGridStyle)