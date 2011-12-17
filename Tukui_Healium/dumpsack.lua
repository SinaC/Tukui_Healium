-----------------------------------------------------
-- DumpSack, code ripped from BugSack
-----------------------------------------------------

-- APIs:
-- DumpSack:Add(line): add a line to buffer
-- DumpSack:Flush(addonName): flush buffer to frame and show it (create frame if not already created)
-- DumpSack:Show(): display Dump
-- DumpSack:Hide(): hide Dump

local ADDON_NAME, ns = ...
if not ns.Enabled then return end

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

-- TODO:
-- prevButton, nextButton: SetDisabledTexture

-- Namespace
DumpSack = {}

-- Local variables
local window = nil
local textArea
local nextButton
local prevButton
local countLabel
local sessionLabel

local currentErrorObject = nil
local currentDumpContents = {}
local currentErrorIndex = 1

local buffer = ""

local sessionFormat = "%s - |cffff4411%s|r" -- <date> - <sent by>
local countFormat = "%d/%d" -- 1/10
local sourceFormat = "Sent by %s (%s)" -- <source> -- <type>

local function UpdateDumpSackDisplay()
	currentErrorObject = currentDumpContents and currentDumpContents[currentErrorIndex]
	local entry = nil
	local size = #currentDumpContents
	for i, v in next, currentDumpContents do
		if v == currentErrorObject then
			currentErrorIndex = i
			entry = v
			break
		end
	end
	if not entry then entry = currentDumpContents[currentErrorIndex] end
	if not entry then entry = currentDumpContents[size] end

	if size > 0 then
		local source = sourceFormat:format(entry.source, entry.type)

		countLabel:SetText(countFormat:format(currentErrorIndex, size))
		sessionLabel:SetText(sessionFormat:format(entry.time, source))
		textArea:SetText(entry.message)

		if currentErrorIndex >= size then
			nextButton:Disable()
		else
			nextButton:Enable()
		end
		if currentErrorIndex <= 1 then
			prevButton:Disable()
		else
			prevButton:Enable()
		end
		if sendButton then sendButton:Enable() end
	else
		countLabel:SetText()
		sessionLabel:SetText(sessionFormat:format(entry.time, source))
		textArea:SetText("No dump")

		nextButton:Disable()
		prevButton:Disable()
		if sendButton then sendButton:Disable() end
	end
end

local function CreateDumpSackFrame()
	window = CreateFrame("Frame", "HealiumDumpFrame", UIParent)
	window:CreatePanel("Default", 500, 500 / 1.618, "CENTER", UIParent, "CENTER", 0, 0 )
	window:SetFrameStrata("FULLSCREEN_DIALOG")
	window:SetMovable(true)
	window:EnableMouse(true)
	window:RegisterForDrag("LeftButton")
	window:SetScript("OnDragStart", window.StartMoving)
	window:SetScript("OnDragStop", window.StopMovingOrSizing)
	window:SetScript("OnHide", function()
		currentErrorObject = nil
	end)

	local titlebg = window:CreateTexture("frame", "BORDER")
	titlebg:SetTexture(1,1,1,0.3)
	titlebg:SetPoint("TOPLEFT", 9, -6)
	titlebg:SetPoint("BOTTOMRIGHT", window, "TOPRIGHT", -28, -24)

	local close = CreateFrame("Button", "HealiumDumpCloseButton", window)
	close:CreatePanel("Default", 20, 20, "TOPRIGHT", window, "TOPRIGHT", -4, -4)
	close:SetFrameStrata("TOOLTIP")
	close:StyleButton(false)
	close:FontString("text", C.media.pixelfont, 12, "MONOCHROME")
	close.text:SetText("X")
	close.text:SetPoint("CENTER", 1, 1)
	close:SetScript("OnClick", DumpSack.Hide)

	sessionLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	sessionLabel:SetJustifyH("LEFT")
	sessionLabel:SetPoint("TOPLEFT", titlebg, 6, -3)
	sessionLabel:SetTextColor(1, 1, 1, 1)

	countLabel = window:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	countLabel:SetPoint("TOPRIGHT", titlebg, -6, -3)
	countLabel:SetJustifyH("RIGHT")
	countLabel:SetTextColor(1, 1, 1, 1)

	prevButton = CreateFrame("Button", "HealiumDumpPrevButton", window)
	prevButton:CreatePanel("Default", 130, 20, "BOTTOMLEFT", window, "BOTTOMLEFT", 20, 16)
	prevButton:SetFrameStrata("TOOLTIP")
	prevButton:StyleButton(false)
	prevButton:FontString("text", C.media.pixelfont, 12, "MONOCHROME")
	prevButton.text:SetText("< Previous")
	prevButton.text:SetPoint("CENTER", 1, 1)
	prevButton:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			currentErrorIndex = 1
		else
			currentErrorIndex = currentErrorIndex - 1
		end
		UpdateDumpSackDisplay()
	end)

	nextButton = CreateFrame("Button", "HealiumDumpNextButton", window)
	nextButton:CreatePanel("Default", 130, 20, "BOTTOMRIGHT", window, "BOTTOMRIGHT", -20, 16)
	nextButton:SetFrameStrata("TOOLTIP")
	nextButton:StyleButton(false)
	nextButton:FontString("text", C.media.pixelfont, 12, "MONOCHROME")
	nextButton.text:SetText("Next >")
	nextButton.text:SetPoint("CENTER", 1, 1)
	nextButton:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			currentErrorIndex = #currentDumpContents
		else
			currentErrorIndex = currentErrorIndex + 1
		end
		UpdateDumpSackDisplay()
	end)

	local scroll = CreateFrame("ScrollFrame", "HealiumDumpScroll", window, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", window, "TOPLEFT", 16, -36)
	scroll:SetPoint("BOTTOMRIGHT", nextButton, "TOPRIGHT", -24, 8)

	textArea = CreateFrame("EditBox", "HealiumDumpScrollText", scroll)
	textArea:SetAutoFocus(false)
	textArea:SetMultiLine(true)
	textArea:SetFontObject(GameFontHighlightSmall)
	textArea:SetMaxLetters(99999)
	textArea:EnableMouse(true)
	textArea:SetScript("OnEscapePressed", textArea.ClearFocus)
	-- XXX why the fuck doesn't SetPoint work on the editbox?
	textArea:SetWidth(450)

	scroll:SetScrollChild(textArea)
	
	window:Hide()
end

function DumpSack:Add(line)
	buffer = buffer .. line .. "\n" -- append text to buffer until a flush is called
end

function DumpSack:Flush(addonName)
	if not window then
		CreateDumpSackFrame()
	end
	local entry = {
		message = buffer,
		locals = nil, -- BugGrabber/BugSack compliance
		stack = nil, -- BugGrabber/BugSack compliance
		source = addonName,
		session = 1, -- BugGrabber/BugSack compliance
		time = date("%Y/%m/%d %H:%M:%S"),
		type = "dump",
		counter = 1, -- BugGrabber/BugSack compliance
	}
	tinsert(currentDumpContents, entry)
	currentErrorIndex = #currentDumpContents
	UpdateDumpSackDisplay()
	DumpSack:Show()
	--local BugGrabber = _G["BugGrabber"]
	--BugGrabber:StoreError(errorObject)
	buffer = "" -- reset current buffer
end

function DumpSack:Show()
	if not window or window:IsShown() then return end
	UpdateDumpSackDisplay()
	window:Show()
end

function DumpSack:Hide()
	if not window or not window:IsShown() then return end
	window:Hide()
end