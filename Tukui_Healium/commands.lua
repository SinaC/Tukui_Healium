-------------------------------------------------------
-- Slash commands
-------------------------------------------------------

local ADDON_NAME, ns = ...

-- Aliases
local Private = ns.Private
local L = ns.Locales

local RegisterCallback = Private.RegisterCallback
local ToggleRaidVisibility = Private.ToggleRaidVisibility

-- Slash commands
SLASH_TUKUIHEALIUM1 = "/thlm"
SLASH_TUKUIHEALIUM2 = "/tukuihealium"

local function SlashHandlerShowHelp()
	print(string.format(L.COMMANDS_HELP_USE, SLASH_TUKUIHEALIUM1, SLASH_TUKUIHEALIUM2))
	-- print(SLASH_TUKUIHEALIUM1.." show - show raid healium frames and hide tukui raid frames") -- TODO: locales
	-- print(SLASH_TUKUIHEALIUM1.." hide - hide raid healium frames and show tukui raid frames") -- TODO: locales
	print(string.format(L.COMMANDS_HELP_TOGGLE, SLASH_TUKUIHEALIUM1)) -- TODO: locales
end

local function SlashHandlerToggle(args)
	ToggleRaidVisibility()
end

-- local function SlashHandlerShow(args)
	-- if InCombatLockdown() then
		-- print("Not while in combat") -- TODO: locales
		-- return
	-- end
	-- --Private.ShowTukuiHealium()
-- end

-- local function SlashHandlerHide(args)
	-- if InCombatLockdown() then
		-- print("Not while in combat") -- TODO: locales
		-- return
	-- end
	-- --Private.HideTukuiHealium()
-- end

SlashCmdList["TUKUIHEALIUM"] = function(cmd)
	local switch = cmd:match("([^ ]+)")
	local args = cmd:match("[^ ]+ (.+)")
	if switch == "toggle" then
		SlashHandlerToggle(args)
	-- elseif switch == "show" then
		-- SlashHandlerShow(args)
	-- elseif switch == "hide" then
		-- SlashHandlerHide(args)
	else
		SlashHandlerShowHelp()
	end
end
