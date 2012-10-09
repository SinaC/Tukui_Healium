-------------------------------------------------------
-- Slash commands
-------------------------------------------------------

local ADDON_NAME, ns = ...

-- Aliases
local Private = ns.Private
local L = ns.Locales

-- Slash commands
SLASH_TUKUIHEALIUM1 = "/thlm"
SLASH_TUKUIHEALIUM2 = "/tukuihealium"

local function SlashHandlerShowHelp()
	print(string.format(L.COMMANDS_HELP_USE, SLASH_TUKUIHEALIUM1, SLASH_TUKUIHEALIUM2))
	print(string.format(L.COMMANDS_HELP_SHOW, SLASH_TUKUIHEALIUM1))
	print(string.format(L.COMMANDS_HELP_HIDE, SLASH_TUKUIHEALIUM1))
	print(string.format(L.COMMANDS_HELP_TOGGLE, SLASH_TUKUIHEALIUM1))
end

local function SlashHandlerToggle(args)
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

local function SlashHandlerShow(args)
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end
	if Private.IsEnabledForCurrentSpec() then
		Private.ERROR(L.ERROR_ALREADYSHOWN)
	else
		Private.EnableForCurrentSpec()
		Private.ShowTukuiHealium()
	end
end

local function SlashHandlerHide(args)
	if InCombatLockdown() then
		Private.ERROR(L.ERROR_NOTINCOMBAT)
		return
	end
	if Private.IsEnabledForCurrentSpec() then
		Private.DisableForCurrentSpec()
		Private.HideTukuiHealium()
	else
		Private.ERROR(L.ERROR_ALREADYHIDDEN)
	end
end

SlashCmdList["TUKUIHEALIUM"] = function(cmd)
	local switch = cmd:match("([^ ]+)")
	local args = cmd:match("[^ ]+ (.+)")
	if switch == "toggle" then
		SlashHandlerToggle(args)
	elseif switch == "show" then
		SlashHandlerShow(args)
	elseif switch == "hide" then
		SlashHandlerHide(args)
	else
		SlashHandlerShowHelp()
	end
end
