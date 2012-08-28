-------------------------------------------------------
-- Normal healium
-------------------------------------------------------

local ADDON_NAME, ns = ...
--local SinaCUI = ns.SinaCUI
--if not SinaCUI.HealiumEnabled then return end

--local Private = SinaCUI.Private
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

-- local backdropr, backdropg, backdropb = unpack(C["media"].backdropcolor)
-- local backdropa = 1
-- local borderr, borderg, borderb = unpack(C["media"].bordercolor)


-- BB BB UnitFrame HH HH HH DD DD DD
-- BB: buff
-- DD: debuff
-- HH: button
local function SkinHealiumButton(frame, button)
	local size = frame:GetHeight()
	----button:SetTemplate("Default")
	button:SetTemplate()
	button:SetSize(size, size)
	----button:SetFrameLevel(1)
	----button:SetFrameStrata("BACKGROUND")
	button.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.texture:ClearAllPoints()
	button.texture:Point("TOPLEFT", button ,"TOPLEFT", 0, 0)
	button.texture:Point("BOTTOMRIGHT", button ,"BOTTOMRIGHT", 0, 0)
	button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
	button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
	button.texture:SetVertexColor(1, 1, 1)
	--button:CreateBackdrop()
	--button:SetBackdropColor(0, 0, 0, 0)
	----button:SetBackdrop(nil)
	--button:SetBackdropColor(0.6, 0.6, 0.6)
	--button:SetBackdropBorderColor(0.1, 0.1, 0.1)
	----print("backdrop: "..tostring(backdropr).."  "..tostring(backdropg).."  "..tostring(backdropb))
	----print("border: "..tostring(borderr).."  "..tostring(borderg).."  "..tostring(borderb))
	----button:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	----button:SetBackdropBorderColor(borderr,borderg, borderb)
end

local function SkinHealiumDebuff(frame, debuff)
	local size = frame:GetHeight()
	debuff:SetTemplate("Default")
	debuff:SetSize(size, size)
	debuff:SetFrameLevel(1)
	debuff:SetFrameStrata("BACKGROUND")
	if debuff.icon then
		debuff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		debuff.icon:ClearAllPoints()
		debuff.icon:Point("TOPLEFT", 2, -2)
		debuff.icon:Point("BOTTOMRIGHT", -2, 2)
	end
	if debuff.count then
		debuff.count:SetFont(C["media"].uffont, 14, "OUTLINE")
		debuff.count:ClearAllPoints()
		debuff.count:Point("BOTTOMRIGHT", 1, -1)
		debuff.count:SetJustifyH("CENTER")
	end
	if debuff.shield then
		-- debuff.shield:SetFont(C["media"].uffont, 12, "OUTLINE")
		-- debuff.shield:ClearAllPoints()
		-- debuff.shield:Point("TOPLEFT", 1, 1)
		-- debuff.shield:SetJustifyH("CENTER")
		debuff.shield:SetFont(C["media"].uffont, 14, "OUTLINE")
		debuff.shield:ClearAllPoints()
		debuff.shield:Point("CENTER",0, 0)
		debuff.shield:SetJustifyH("CENTER")

	end
end

local function SkinHealiumBuff(frame, buff)
	local size = frame:GetHeight()
	buff:SetTemplate("Default")
	buff:SetSize(size, size)
	buff:SetFrameLevel(1)
	buff:SetFrameStrata("BACKGROUND")
	if buff.icon then
		buff.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		buff.icon:ClearAllPoints()
		buff.icon:Point("TOPLEFT", 2, -2)
		buff.icon:Point("BOTTOMRIGHT", -2, 2)
	end
	if buff.count then
		buff.count:SetFont(C["media"].uffont, 14, "OUTLINE")
		buff.count:ClearAllPoints()
		buff.count:Point("BOTTOMRIGHT", 1, -1)
		buff.count:SetJustifyH("CENTER")
	end
	if buff.shield then
		-- buff.shield:SetFont(C["media"].uffont, 12, "OUTLINE")
		-- buff.shield:ClearAllPoints()
		-- buff.shield:Point("TOPLEFT", 1, 1)
		-- buff.shield:SetJustifyH("CENTER")
		buff.shield:SetFont(C["media"].uffont, 14, "OUTLINE")
		buff.shield:ClearAllPoints()
		buff.shield:Point("CENTER",0, 0)
		buff.shield:SetJustifyH("CENTER")
	end
end

local HealiumNormalStyle = {
	--CreateButton = CreateHealiumButton,
	--CreateDebuff = CreateHealiumDebuff,
	--CreateBuff = CreateHealiumBuff,
	SkinButton = SkinHealiumButton,
	SkinDebuff = SkinHealiumDebuff,
	SkinBuff = SkinHealiumBuff,
}
H:RegisterStyle("TukuiHealiumNormal", HealiumNormalStyle)