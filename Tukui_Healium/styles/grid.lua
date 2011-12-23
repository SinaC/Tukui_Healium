
-- Grid healium
-------------------------------------------------------

local ADDON_NAME, ns = ...
if not ns.Enabled then return end

local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

-- TODO: move this to config file
local buttonSpacing = 0
--local debuffSpacing = 0
local buffSpacing = 0
local healthHeight = 27
local buttonSize = 20
local buttonByRow = 5
local buffSize = 16
local debuffSize = 16
local initialWidth = buttonByRow*buttonSize
local initialHeight = 2*buttonSize + healthHeight
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
	button:Size(buttonSize, buttonSize)
	--button:SetFrameStrata("BACKGROUND")
	button:SetFrameLevel(9)
	--button:SetFrameStrata(frame:GetFrameStrata())
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
	debuff:Size(debuffSize, debuffSize)
	--debuff:SetFrameStrata("BACKGROUND")
	debuff:SetFrameLevel(9)
	--debuff:SetFrameStrata(parent:GetFrameStrata())
	if debuff.icon then
		debuff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		debuff.icon:ClearAllPoints()
		debuff.icon:Point("TOPLEFT", 1, -1)
		debuff.icon:Point("BOTTOMRIGHT", -1, 1)
	end
	if debuff.count then
		debuff.count:SetFont(C["media"].uffont, 14, "OUTLINE")
		debuff.count:ClearAllPoints()
		debuff.count:Point("BOTTOMRIGHT", 1, -1)
		debuff.count:SetJustifyH("CENTER")
	end
	if debuff.shield then
		debuff.shield:SetFont(C["media"].uffont, 12, "OUTLINE")
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
	buff:Size(buffSize, buffSize)
	--buff:SetFrameStrata("BACKGROUND")
	buff:SetFrameLevel(9)
	--buff:SetFrameStrata(parent:GetFrameStrata())
	buff:SetBackdrop(nil)
	if buff.icon then
		buff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		buff.icon:SetAllPoints(buff)
	end
	if buff.count then
		buff.count:SetFont(C["media"].uffont, 14, "OUTLINE")
		buff.count:ClearAllPoints()
		buff.count:Point("BOTTOMRIGHT", 1, -1)
		buff.count:SetJustifyH("CENTER")
	end
	if buff.shield then
		buff.shield:SetFont(C["media"].uffont, 12, "OUTLINE")
		buff.shield:ClearAllPoints()
		buff.shield:Point("TOPLEFT", 1, 1)
		buff.shield:SetJustifyH("CENTER")
	end
end

local function AnchorGridButton(frame, button, buttonList, index)
	-- Matrix-positioning
	local anchor
	if index == 1 then
print(tostring(index).." 1")
		anchor = {"TOPLEFT", frame.Health, "BOTTOMLEFT", 0, 0}
	elseif (index % buttonByRow) == 1 then
print(tostring(index).." 2")
		anchor = {"TOPLEFT", buttonList[index-buttonByRow], "BOTTOMLEFT", 0, 0}
	else
print(tostring(index).." 3")
		anchor = {"TOPLEFT", buttonList[index-1], "TOPRIGHT", 0, 0}
	end
	button:ClearAllPoints()
	button:Point(unpack(anchor))
end

local function AnchorGridDebuff(frame, debuff, debuffList, index)
	-- Fixed-positioning
	local anchor = {"BOTTOMLEFT", frame.Health, "BOTTOMLEFT", 10, 1}
	debuff:ClearAllPoints();
	debuff:Point(unpack(anchor))
end

local function AnchorGridBuff(frame, buff, buffList, index)
	-- Line-positioning
	local anchor
	if index == 1 then
		anchor = {"BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -1, 1}
	else
		anchor = {"TOPRIGHT", buffList[index-1], "TOPLEFT", 0, 0}
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