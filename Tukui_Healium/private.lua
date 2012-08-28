local ADDON_NAME, ns = ...

local Private = ns.Private
local L = ns.Locales

function Private.ERROR(...)
	local line = "|CFFFF0000TukuiHealium|r:" .. strjoin(" ", ...)
	print(line)
end

function Private.WARNING(...)
	local line = "|CFFFFFF00TukuiHealium|r:" .. strjoin(" ", ...)
	print(line)
end

function Private.INFO(...)
	local line = "|CFFFFFFFFTukuiHealium|r:" .. strjoin(" ", ...)
	print(line)
end

--[[
-- Delayed actions
local DelayedActionEventHandler = CreateFrame("Frame")
local DelayedActionsPending = false
local DelayedActions = {}

DelayedActionEventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
DelayedActionEventHandler:SetScript("OnEvent", function()
	if InCombatLockdown() then return end -- SHOULD NEVER HAPPEN
	if DelayedActionsPending == true then
		for _, item in pairs(DelayedActions) do
print("DELAYED CALL: "..tostring(item.fct))
			item.fct(item.args)
		end
		DelayedActionsPending = false
	end
end)

function Private.DelayedAction(fct, ...)
	if InCombatLockdown() then
		-- Save action
		tinsert(DelayedActions, {fct = fct, args = ...})
		DelayedActionsPending = true
	else
		-- Direct call
		fct(...)
	end
end
--]]

-- Callbacks
local Callbacks = {}
function Private.RegisterCallback(trigger, fct, ...)
	if not trigger or not fct then return false end
	if not type(trigger) == "string" then return false end
	if not type(priority) == "number" then return false end
	if not type(fct) == "function" then return false end
	if not Callbacks[trigger] then Callbacks[trigger] = {} end
	local list = Callbacks[trigger]
	tinsert(list, {fct = fct, args = ...})
	return true
end

function Private.FireCallback(trigger)
	if not trigger then return false end
	local list = Callbacks[trigger]
	if not list then return false end
	for _, item in pairs(list) do
--print("CALLBACK: "..tostring(item.fct))
		item.fct(item.args)
	end
	return true
end

-- Visibility
function Private.ShowTukuiHealium(force)
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end

	if not force and TukuiHealiumDataPerCharacter.show == true then
		Private.ERROR(L.ERROR_ALREADYSHOWN)
		return
	end
	-- Show own raid frames
	TukuiHealiumRaid25Header:SetParent(TukuiPetBattleHider)
	-- TODO: TukuiHealiumRaidPets25Header

	-- Hide tukui raid frames
	TukuiRaid:SetParent(TukuiUIHider)
	TukuiRaidPet:SetParent(TukuiUIHider)

	Private.INFO(string.format(L.INFO_SHOW, SLASH_TUKUIHEALIUM1))
	TukuiHealiumDataPerCharacter.show = true
--print("ShowTukuiHealium:"..tostring(TukuiHealiumDataPerCharacter.show))
	Private.FireCallback("ShowRaidFrames")
end

function Private.HideTukuiHealium(force)
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end

	if not force and TukuiHealiumDataPerCharacter.show == false then
		Private.ERROR(L.ERROR_ALREADYHIDDEN)
		return
	end
	-- Hide own raid frames
	TukuiHealiumRaid25Header:SetParent(TukuiUIHider)
	-- TODO: TukuiHealiumRaidPets25Header

	-- Hide tukui raid frames
	TukuiRaid:SetParent(TukuiPetBattleHider)
	TukuiRaidPet:SetParent(TukuiPetBattleHider)

	Private.INFO(string.format(L.INFO_HIDE, SLASH_TUKUIHEALIUM1)) 
	TukuiHealiumDataPerCharacter.show = false
--print("HideTukuiHealium:"..tostring(TukuiHealiumDataPerCharacter.show))
	Private.FireCallback("HideRaidFrames")
end

function Private.ToggleRaidVisibility()
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end

	if TukuiHealiumDataPerCharacter.show == true then
		Private.HideTukuiHealium()
	else
		Private.ShowTukuiHealium()
	end
end