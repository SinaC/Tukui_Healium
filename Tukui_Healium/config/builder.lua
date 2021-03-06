local _, ns = ...
local T, C, L = unpack(Tukui)

ns.Builder = {}
local B = ns.Builder

--[[
	B:CreateOptionPanel(parent, name, definition, config) return panel
	B:BuildDefaultOptions(definition) return default config matching definition
	B:ComputeHash(t) return hash
	B:DeepCopy(object) return a duplicated copy of object
--]]

-----------------------
-- Duplicate any object
function B:DeepCopy(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		local new_table = {}
		lookup_table[object] = new_table
		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end
		return new_table
	end
	return _copy(object)
end

function B:ComputeHash(value)
	-- djb2 hash function   http://www.cse.yorku.ca/~oz/hash.html
	local hash = 5381
	if type(value) == "table" then
		for k, v in pairs(value) do
			hash = hash + B:ComputeHash(v)
		end
	else
		local str = tostring(value)
		local len = string.len(str)
		for i = 1, len do
			hash = (hash * 33 + string.byte(str, i)) % 2147483648
		end
	end
	return hash
end

-- function B:BuildTableHash(t)
	-- -- djb2 hash function   http://www.cse.yorku.ca/~oz/hash.html
	-- local hash = 5381
	-- for k, v in pairs(t) do
		-- if type(v) == "table" then
			-- hash = hash + B:BuildTableHash(v)
		-- else
			-- local str = tostring(v)
			-- local len = string.len(str)
			-- for i = 1, len do
				-- hash = (hash * 33 + string.byte(str, i)) % 2147483648
			-- end
		-- end
	-- end
	-- return hash
-- end
-----------------------

local function GetValue(option, config)
	local value
	if option.get and type(option.get) == "function" then -- call getter if exists
		value = option.get(option, config)
	elseif option.key then -- get key if exists
		value = config[option.key]
	end
--print("GetValue: "..tostring(option.name).." => "..tostring(value))
	if value == nil and not option.optional then -- if not value set and not optional, use default
--print("defaulting: "..tostring(option.name))
		value = option.default
	end
	return value
end

local function SetValue(value, option, config)
--print("SetValue: "..tostring(value))
	if option.set and type(option.set) == "function" then -- set key if exists
		option.set(value, option, config)
	elseif option.key then -- call setter if exists
		config[option.key] = value
	end
end

local function CheckboxHandler(self)
	-- get current value
	local checked = self:GetChecked() and true or false
	SetValue(checked, self.option, self.config)
end

local function SliderHandler(self, value)
	SetValue(tonumber(value), self.option, self.config)
end

local function EditboxHandler(self)
	local value = self:GetText()
	SetValue(value, self.option, self.config)
end

local function ColorPickerHandler(button)
	if ColorPickerFrame:IsShown() then return end

	local function ColorCallback(restore)
		if restore ~= nil or button ~= ColorPickerFrame.button then return end

		local a, r, g, b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()
		local value = {r, g, b, a}
		SetValue(value, button.option, button.config)
		button:SetBackdropBorderColor(r, g, b, a)
	end

	local function CancelCallback()
		SetValue(button.previousValue, button.option, button.config)
		button:SetBackdropBorderColor(unpack(button.previousValue))
	end

	local function OnHide(self)
		if self.originalFrameStrata then ColorPickerFrame:SetFrameStrata(self.originalFrameStrata) end
		if self.originalFrameLevel then ColorPickerFrame:SetFrameLevel(self.originalFrameLevel) end
		self.originalFrameStrata = nil
		self.originalFrameLevel = nil
	end

	local r, g, b, a = unpack(button.previousValue)
	HideUIPanel(ColorPickerFrame)
	ColorPickerFrame.originalFrameStrata = ColorPickerFrame:GetFrameStrata() -- save strata
	ColorPickerFrame.originalFrameLevel = ColorPickerFrame:GetFrameLevel() -- save level
	ColorPickerFrame:SetFrameStrata(button:GetParent():GetFrameStrata()) -- set strata
	ColorPickerFrame:SetFrameLevel(button:GetParent():GetFrameLevel()+1) -- set level
	ColorPickerFrame:SetPoint("TOPLEFT", button, "TOPRIGHT", 0, 0)
	ColorPickerFrame.button = button -- save button
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame.hasOpacity = (a ~= nil and a < 1)
	ColorPickerFrame.opacity = a
	ColorPickerFrame.previousValues = {r, g, b, a}
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = ColorCallback, ColorCallback, CancelCallback
	if not ColorPickerFrame.restoreFrameStrataLevelFuncSet then
		ColorPickerFrame:HookScript("OnHide", OnHide)
		ColorPickerFrame.restoreFrameStrataLevelFuncSet = true
	end
	ShowUIPanel(ColorPickerFrame)
end

local function DropdownItemHandler(self)
--print(tostring(self:GetID()).."  "..tostring(self.value))
	UIDropDownMenu_SetSelectedID(self.owner, self:GetID())
	SetValue(self.value, self.owner.option, self.owner.config)

	-- print("DUMP CONFIG")
	-- for k, v in pairs(self.owner.config) do
		-- local s = ""
		-- if type(v) == "table" then
			-- s = s .. "("
			-- for k1, v1 in pairs(v) do
				-- s = s .. tostring(k1).." => "..tostring(v1)
			-- end
			-- s = s .. ")"
		-- else
			-- s = tostring(v)
		-- end
		-- print(tostring(k).." ==> "..s)
	-- end
end
local function DropdownInitialize(self, level)
	local currentValue = GetValue(self.option, self.config)
	local values = (type(self.option.values) == "function") and self.option.values(self.option, self.config) or self.option.values
	if values then
		--local hash = B:ComputeHash(values)
		--if self.hash ~= hash then -- only if hash is different
--print("hash:"..tostring(hash))
			for index, desc in pairs(values) do
--print(tostring(index).."  "..tostring(desc.text).."  "..tostring(desc.value).."  "..(self.currentValue == desc.value and "SELECTED" or ""))
				local node = UIDropDownMenu_CreateInfo()
				node.text = desc.text
				node.value = desc.value
				node.icon = desc.icon
				node.owner = self
				node.func = DropdownItemHandler
				UIDropDownMenu_AddButton(node, level)
				if currentValue == desc.value then
					UIDropDownMenu_SetSelectedID(self, index)
				end
			end
			--self.hash = hash
		--end
	end
end

local function MultiCheckboxHandler(self)
	local checked = self:GetChecked() and true or false -- get check state
	local currentValue = GetValue(self.option, self.config) -- get current value
--print("CHECKED:"..tostring(self:GetName()).."  "..tostring(checked).."  "..tostring(self.value))
	if checked then
		if not currentValue then
			currentValue = {self.value}
		else
			tinsert(currentValue, self.value)
		end
		SetValue(currentValue, self.option, self.config)
	else
		if currentValue then
			for index, value in pairs(currentValue) do
				if value == self.value then
					tremove(currentValue, index)
					break
				end
			end
			SetValue(currentValue, self.option, self.config)
		end
	end
end

--
function B:CreateCheckbox(parent, name, text, onClick)
	local checkbox = _G[name]
	if not checkbox then
		checkbox = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
		checkbox:SkinCheckBox()
		_G[name.."Text"]:SetFont(C.media.font, 12)
		checkbox:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		checkbox:SetScript("OnClick", onClick)
		checkbox.backdrop:SetBackdropColor(0, 0, 0, 0)
	end
	_G[name.."Text"]:SetText(text)

	return checkbox
end

function B:CreateSlidebar(parent, name, text, min, max, step, onValueChanged)
	local slidebar = _G[name]
	if not slidebar then
		slidebar = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
		slidebar:SkinSlideBar()
		slidebar:SetScript("OnValueChanged", onValueChanged)
	end
	slidebar:SetValueStep(step or 1)
	slidebar:SetMinMaxValues(min, max)
	_G[slidebar:GetName() .. "Low"]:SetText(tostring(min))
	_G[slidebar:GetName() .. "High"]:SetText(tostring(max))
	_G[slidebar:GetName() .. "Text"]:SetText(text)

	return slidebar
end

function B:CreateLabel(parent, name, text, width, height)
	local label = _G[name]
	if not label then
		label = parent:CreateFontString(name, "OVERLAY", nil)
		label:SetFont(C.media.font, 12)
		label:SetJustifyH("LEFT")
	end
	if width then label:SetWidth(width) end
	if height then label:SetHeight(height) end
	label:SetText(text)

	return label
end

function B:CreateEditbox(parent, name, width, height, editboxHandler)
	-- editbox
	local editbox = _G[name]
	if not editbox then
		editbox = CreateFrame("EditBox", name, parent)
		editbox:SetAutoFocus(false)
		editbox:SetMultiLine(false)
		editbox:SetMaxLetters(255)
		editbox:SetTextInsets(3, 0, 0, 0)
		editbox:SetBackdrop({
			bgFile = C.media.blank,
			tiled = false,
		})
		editbox:SetBackdropColor(0, 0, 0, 0.5)
		editbox:SetBackdropBorderColor(0, 0, 0, 1)
		editbox:SetFontObject(GameFontHighlight)
	end
	if width then editbox:SetWidth(width) end
	if height then editbox:SetHeight(height) end
	editbox:SetTemplate()

	-- ok button
	local buttonName = name.."_BUTTON"
	local button = _G[buttonName]
	if not button then
		button = CreateFrame("Button", buttonName, parent)
		button:SetHeight(editbox:GetHeight())
		button:SetWidth(editbox:GetHeight())
		button:SetTemplate("Default")
		button:SetPoint("LEFT", editbox, "RIGHT", 2, 0)
		button.text = button:CreateFontString(nil, "OVERLAY", nil)
		button.text:SetFont(C.media.font, 12)
		button.text:SetText("OK")
		button.text:SetPoint("CENTER", 1, 0)
		button.text:SetJustifyH("CENTER")
	end
	button:Hide()

	editbox:SetScript("OnEscapePressed", function(self)
		button:Hide()
		self:ClearFocus()
		self.noTextChanged = true
		self:SetText(self.previousValue)
		self.noTextChanged = false
	end)
	-- editbox:SetScript("OnChar", function(self)
		-- button:Show()
	-- end)
	editbox:SetScript("OnTextChanged", function(self)
		if not self.noTextChanged --[[ and string.len(self:GetText()) > 0--]] then
			button:Show()
		end
	end)
	editbox:SetScript("OnEnterPressed", function(self)
		button:Hide()
		self:ClearFocus()
		editboxHandler(self)
		self.previousValue = self:GetText()
	end)
	button:SetScript("OnMouseDown", function(self)
		editbox:ClearFocus()
		self:Hide()
		editboxHandler(editbox)
		self.previousValue = self:GetText()
	end)

	return editbox
end

function B:CreateButton(parent, name, text, width, height, onMouseDown)
	local button = _G[name]
	if not button then
		button = CreateFrame("Button", name, parent)
		button:SetTemplate()
		button.text = button:CreateFontString(nil, "OVERLAY", nil)
		button.text:SetFont(C.media.font, 12)
		button.text:SetText(text)
		button.text:SetPoint("CENTER")
		button.text:SetJustifyH("CENTER")
		button:SetScript("OnMouseDown", onMouseDown)
	end
	button:SetWidth(width)
	button:SetHeight(height or width)

	return button
end
--
function B:CreateOptionPanel(parent, name, definition, config)
	local frame = _G[name]
	if not frame then frame = CreateFrame("Frame", name, parent) end
	frame:Size(parent:GetWidth()-20, 1000)

	local offset = 0
	for index, option in ipairs(definition) do
--print("CreateOptionPanel:"..tostring(name).."  "..tostring(index).."  "..tostring(option))
		-- current value
		local value = GetValue(option, config)
		assert(value ~= nil or option.optional or option.type == "custom", "No value found for option:"..tostring(index).." "..tostring(option.name))
		-- frame
		if option.type == "toggle" then
			-- toggle: checkbox
			local checkbox = B:CreateCheckbox(frame, name.."_CHECKBOX_"..index.."_"..option.name, option.name, CheckboxHandler)
			checkbox:ClearAllPoints()
			checkbox:SetPoint("TOPLEFT", 5, -(offset))

			checkbox.config = config
			checkbox.option = option
			checkbox:SetChecked(value)

			offset = offset + 25
		elseif option.type == "number" then
			assert(option.min ~= nil and option.max ~= nil, "Min or max is missing for option:"..tostring(index).." "..tostring(option.name))
			-- number: slidebar
			local slidebar = B:CreateSlidebar(frame, name.."_SLIDEBAR_"..index.."_"..option.name, option.name, option.min, option.max, option.step, SliderHandler)
			slidebar:ClearAllPoints()
			slidebar:SetPoint("TOPLEFT", 5, -(15+offset))

			slidebar.config = config
			slidebar.option = option
			slidebar:SetValue(value)
-- TODO: display current value in SliderHandler

			offset = offset + 40
		elseif option.type == "string" then
			-- string: label + editbox + button ok
			-- label
			local label = B:CreateLabel(frame, name.."_LABEL_"..index.."_"..option.name, option.name, frame:GetWidth()-60, 20)
			label:ClearAllPoints()
			label:SetPoint("TOPLEFT", 5, -(offset))

			-- editbox
			local editbox = B:CreateEditbox(frame, name.."_EDITBOX_"..index.."_"..option.name, frame:GetWidth()-60, 20, EditboxHandler)
			editbox:ClearAllPoints()
			editbox:SetPoint("TOPLEFT", 5, -(offset+20))

			editbox.config = config
			editbox.option = option
			editbox.previousValue = value
			editbox:SetText(value)

			offset = offset + 45
		elseif option.type == "select" then
			assert(option.values, "Values not found for option:"..tostring(index).." "..tostring(option.name))
			-- select: label + dropdown
			-- label
			local label = B:CreateLabel(frame, name.."_LABEL_"..index.."_"..option.name, option.name, nil, 20)
			label:ClearAllPoints()
			label:SetPoint("TOPLEFT", 5, -(offset))

			-- dropdown
--print("DROPDOWN:"..tostring(option.name))
			local dropdownName = name.."_DROPDOWN_"..index.."_"..option.name
			local dropdown = _G[dropdownName]
			if not dropdown then
				dropdown = CreateFrame("Button", dropdownName, frame, "UIDropDownMenuTemplate")
				UIDropDownMenu_JustifyText(dropdown, "LEFT")
				--UIDropDownMenu_SetWidth(dropdown, 100)
				--UIDropDownMenu_SetButtonWidth(dropdown, 124)
			end
			dropdown:ClearAllPoints()
			dropdown:SetPoint("TOPLEFT", 80, -offset)

			--dropdown:SetFrameLevel(parent:GetFrameLevel()+1)

			-- dropdown:SkinDropDownBox(200)
			-- dropdown.backdrop:Kill()

			-- local width = 200
			-- local button = _G[dropdown:GetName().."Button"]
			-- if not width then width = 155 end

			-- dropdown:StripTextures()
			-- dropdown:Width(width)

			-- local text = _G[dropdown:GetName().."Text"]
			-- text:ClearAllPoints()
			-- text:SetPoint("RIGHT", button, "LEFT", -2, 0)

			-- button:ClearAllPoints()
			-- button:SetPoint("RIGHT", dropdown, "RIGHT", -10, 3)
			-- --button.SetPoint = T.dummy

			-- button:SkinNextPrevButton(true)

			-- -- dropdown:CreateBackdrop("Default")
			-- -- dropdown.backdrop:ClearAllPoints()
			-- -- dropdown.backdrop:SetPoint("TOPLEFT", 20, -2)
			-- -- dropdown.backdrop:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)

			dropdown.config = config
			dropdown.option = option

--print(button:GetFrameStrata().."  "..button:GetFrameLevel().."  "..dropdown.backdrop:GetFrameStrata().."  "..dropdown.backdrop:GetFrameLevel().."  "..dropdown:GetFrameStrata().."  "..dropdown:GetFrameLevel())

			UIDropDownMenu_Initialize(dropdown, DropdownInitialize)

			offset = offset + 25
		elseif option.type == "multiselect" then
			assert(option.values and (value == nil or type(value) == "table"), "Values not found for option:"..tostring(index).." "..tostring(option.name))
			-- multiselect: label + multiple checkboxes
			-- label
			local label = B:CreateLabel(frame, name.."_LABEL_"..index.."_"..option.name, option.name)
			label:ClearAllPoints()
			label:SetPoint("TOPLEFT", 5, -(offset))
			offset = offset + 25
			-- multiple checkboxes
			local values = type(option.values) == "function" and option.values() or option.values

			local xOffset = 0
			local checkboxes = {}
			for i, entry in ipairs(values) do
				local checkbox = B:CreateCheckbox(frame, name.."_MULTICHECKBOX_"..index.."_"..option.name.."_"..i, entry.text, MultiCheckboxHandler)
				checkbox:ClearAllPoints()
				if 1 == (i % 3) then
					checkbox:SetPoint("TOPLEFT", 5, -(offset))
				else
					checkbox:SetPoint("TOPLEFT", 5 + xOffset, -(offset))
				end
				if 0 == (i % 3) then
					offset = offset + 25
					xOffset = 0
				else
					xOffset = xOffset + 150
				end

				checkbox.value = entry.value
				checkbox.config = config
				checkbox.option = option

				checkbox:SetChecked(false) -- default: unselected
				if value ~= nil then
					for _, v in pairs(value) do
						if v == entry.value then
							checkbox:SetChecked(true) -- select if found in value
						end
					end
				end

				checkbox.checkboxes = checkboxes -- keep a pointer to checkbox list
				tinsert(checkboxes, checkbox)
			end
			if 0 ~= (getn(checkboxes) % 3) then
				offset = offset + 25
			end
		elseif option.type == "color" then
			assert(type(value) == "table", "Color is not a table for option:"..tostring(index).." "..tostring(option.name))
			-- color: label + button + color picker
			-- label
			local label = B:CreateLabel(frame, name.."_LABEL_"..index.."_"..option.name, option.name, 100, 20)
			label:ClearAllPoints()
			label:SetPoint("TOPLEFT", 5, -(offset))

			-- button
			local button = B:CreateButton(frame, name.."_BUTTON_"..index.."_"..option.name, "Set Color", 50, 20, ColorPickerHandler)
			button:ClearAllPoints()
			button:SetPoint("LEFT", label, "RIGHT", 2, 0)
			button:SetBackdropBorderColor(unpack(value))

			button.config = config
			button.option = option
			button.previousValue = value

			offset = offset + 25
		elseif option.type == "anchor" then
			-- TODO
			-- selector for point
			-- button for relativeFrame
			-- selector for relativePoint
			-- slider for offset X
			-- slider for offset Y
			-- button SHOW to show actual anchor frame (except if UIParent or Hider), display a red rectangle with frame name
			local point, relativeFrame, relativePoint, offsetX, offsetY = unpack(value)
		elseif option.type == "custom" then
			assert(option.build, "Build entry needed for custom option:"..tostring(index).." "..tostring(option.name))
			offset = offset + option.build(frame, name, offset, option, config)
		else
			assert(false, "Invalid type for option:"..tostring(index).." "..tostring(option.name))
		end
	end
	frame:Height(offset)
	return frame
end

function B:BuildDefaultOptions(definition)
	local config = {}
	for index, option in ipairs(definition) do
		if not option.optional and option.key then
			assert(option.default, "Default value for "..option.name.." is needed to build defaut options")
			config[option.key] = option.default
		end
	end
	return config
end