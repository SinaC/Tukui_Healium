local ADDON_NAME, ns = ...
local H = unpack(HealiumCore)

-- Aliases
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

-----------------------
-- Saved variables
function Private.IsGloballyEnabled()
	return TukuiHealiumDataPerCharacter.enabled
end

function Private.IsEnabledForCurrentSpec()
	local spec = GetSpecialization()
	return spec and TukuiHealiumDataPerCharacter.settings[spec].enabled
end

function Private.EnableForCurrentSpec()
	local spec = GetSpecialization()
	if not spec then return end
	TukuiHealiumDataPerCharacter.settings[spec].enabled = true
end

function Private.DisableForCurrentSpec()
	local spec = GetSpecialization()
	if not spec then return end
	TukuiHealiumDataPerCharacter.settings[spec].enabled = false
end

-----------------------
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

-----------------------
-- Visibility
function Private.ShowTukuiHealium()
	-- Show own raid frames
	if TukuiHealiumRaid25Header then
		TukuiHealiumRaid25Header:SetParent(TukuiPetBattleHider)
	end
	H:Enable()
	-- TODO: TukuiHealiumRaidPets25Header

	-- Hide tukui raid frames
	if TukuiRaid then
		TukuiRaid:SetParent(TukuiUIHider)
		--TukuiRaid:Disable() TODO
	end
	if TukuiRaidPet then
		TukuiRaidPet:SetParent(TukuiUIHider)
		--TukuiRaidPet:Disable() TODO
	end
-- TODO: MainTank, MainAssist

	Private.INFO(string.format(L.INFO_SHOW, SLASH_TUKUIHEALIUM1))
	Private.FireCallback("ShowRaidFrames")
end

function Private.HideTukuiHealium()
	-- Hide own raid frames
	if TukuiHealiumRaid25Header then
		TukuiHealiumRaid25Header:SetParent(TukuiUIHider)
	end
	H:Disable()
	-- TODO: TukuiHealiumRaidPets25Header

	-- Show tukui raid frames
	if TukuiRaid then
		TukuiRaid:SetParent(TukuiPetBattleHider)
		--TukuiRaid:Enable() TODO
	end
	if TukuiRaidPet then
		TukuiRaidPet:SetParent(TukuiPetBattleHider)
		--TukuiRaidPet:Enable() TODO
	end
-- TODO: MainTank, MainAssist

	Private.INFO(string.format(L.INFO_HIDE, SLASH_TUKUIHEALIUM1)) 
	Private.FireCallback("HideRaidFrames")
end