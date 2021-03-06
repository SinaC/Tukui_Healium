-------------------------------------------------------
-- Normal healium
-------------------------------------------------------

local ADDON_NAME, ns = ...
--local SinaCUI = ns.SinaCUI
--if not SinaCUI.HealiumEnabled then return end

--local Private = SinaCUI.Private
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

local Noop = function() end

-- local backdropr, backdropg, backdropb = unpack(C["media"].backdropcolor)
-- local backdropa = 1
-- local borderr, borderg, borderb = unpack(C["media"].bordercolor)


-- BB BB UnitFrame HH HH HH DD DD DD
-- BB: buff
-- DD: debuff
-- HH: button
local function SkinHealiumButton(frame, button)
--[[
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
--]]
	-- local size = frame:GetHeight()
	-- button:SetSize(size, size)

	-- button:SetTemplate()
	-- button:SkinButton()
	-- button.texture:SetTexCoord(.08, .92, .08, .92)
	-- button.texture:ClearAllPoints()
	-- button.texture:SetAllPoints()
	-- button.texture:Point("TOPLEFT", button, 2, -2)
	-- button.texture:Point("BOTTOMRIGHT", button, -2, 2)

	--button:SkinIconButton()
	--button.texture:SetTexCoord(.08,.88,.08,.88)
	----button.backdrop:SetAllPoints()

	-- button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
	-- button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
	-- local pushedTexture = button:GetPushedTexture()
	-- pushedTexture:SetTexCoord(.08, .92, .08, .92)
	-- pushedTexture:ClearAllPoints()
	-- pushedTexture:SetAllPoints()
	-- pushedTexture:Point("TOPLEFT", button, 2, -2)
	-- pushedTexture:Point("BOTTOMRIGHT", button, -2, 2)

	-- local size = frame:GetHeight()
	-- button:SetSize(size, size)
	-- button:SetTemplate()
	-- button:StyleButton()
	-- button.texture:SetTexCoord(.08, .92, .08, .92)
	-- button.texture:ClearAllPoints()
	-- button.texture:SetAllPoints()
	-- button.texture:Point("TOPLEFT", button, 2, -2)
	-- button.texture:Point("BOTTOMRIGHT", button, -2, 2)

	button:CreateBackdrop()
	button.Backdrop:SetOutside(Button, 0, 0)
	button.texture:SetTexCoord(unpack(T.IconCoord))
	button.texture:ClearAllPoints()
	button.texture:SetInside()
	button:SetNormalTexture("")
	button.SetNormalTexture = Noop
	button:StyleButton()
	button.cooldown.healiumFontSize = 10
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
		debuff.count:SetFont(C.Medias.Font, 10, "OUTLINE")
		debuff.count:ClearAllPoints()
		debuff.count:Point("BOTTOMRIGHT", 1, -1)
		debuff.count:SetJustifyH("CENTER")
	end
	if debuff.shield then
		-- debuff.shield:SetFont(C.Medias.Font, 12, "OUTLINE")
		-- debuff.shield:ClearAllPoints()
		-- debuff.shield:Point("TOPLEFT", 1, 1)
		-- debuff.shield:SetJustifyH("CENTER")
		debuff.shield:SetFont(C.Medias.Font, 10, "OUTLINE")
		debuff.shield:ClearAllPoints()
		debuff.shield:Point("CENTER",0, 0)
		debuff.shield:SetJustifyH("CENTER")
	end
	debuff.cooldown.healiumFontSize = 10
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
	-- if buff.cooldown and buff.icon then
		-- buff.cooldown:SetFont(C.Medias.Font, 14, "OUTLINE")
		-- buff.cooldown:SetAllPoints(buff.icon)
		-- buff.cooldown:SetReverse()
	-- end
	if buff.count then
		buff.count:SetFont(C.Medias.Font, 10, "OUTLINE")
		--local Font = T.GetFont(C["ActionBars"].Font)
		--buff.count:SetFontObject(Font)
		buff.count:ClearAllPoints()
		buff.count:Point("BOTTOMRIGHT", 1, -1)
		buff.count:SetJustifyH("CENTER")
	end
	if buff.shield then
		-- buff.shield:SetFont(C.Medias.Font, 12, "OUTLINE")
		-- buff.shield:ClearAllPoints()
		-- buff.shield:Point("TOPLEFT", 1, 1)
		-- buff.shield:SetJustifyH("CENTER")
		buff.shield:SetFont(C.Medias.Font, 10, "OUTLINE")
		buff.shield:ClearAllPoints()
		buff.shield:Point("CENTER",0, 0)
		buff.shield:SetJustifyH("CENTER")
	end
	buff.cooldown.healiumFontSize = 10
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