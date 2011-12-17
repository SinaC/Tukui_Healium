-------------------------------------------------------
-- Slash commands
-------------------------------------------------------
local T, C, L = unpack(Tukui)
local H = unpack(HealiumCore)

-- Aliases
local PerformanceCounter = H.PerformanceCounter

SLASH_THLM1 = "/thlm"
SLASH_THLM2 = "/tukuihealium"
local LastPerformanceCounterReset = GetTime()
local function SlashHandlerShowHelp()
	print(string.format(L.healium_CONSOLE_HELP_GENERAL, SLASH_THLM1, SLASH_THLM2))
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_DUMPGENERAL)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_DUMPFULL)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_DUMPUNIT)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_DUMPPERF)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_DUMPSHOW)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_RESETPERF)
	print(SLASH_THLM1..L.healium_CONSOLE_HELP_TOGGLE)
end

local function SlashHandlerDump(args)
	local function CountEntry(t)
		local count = 0
		for k, v in pairs(t) do
			count = count + 1
		end
		return count
	end
	local function Dump(level, k, v)
		local pad = ""
		for i = 1, level, 1 do
			pad = pad .. "  "
		end
		if type(v) == "table" then
			local count = CountEntry(v)
			if count > 0 then
				if k then
					DumpSack:Add(pad..tostring(k))
				end
				for key, value in pairs(v) do
					Dump(level+1, key, value)
				end
			end
		else
			DumpSack:Add(pad..tostring(k).."="..tostring(v))
		end
	end
	if not args then
		local infos = H:DumpInformation(true)
		if infos then
			Dump(0, nil, infos)
			DumpSack:Flush("Healium_SinaCUI")
		end
	elseif args == "full" then
		local infos = H:DumpInformation(false)
		if infos then
			Dump(0, nil, infos)
			DumpSack:Flush("Healium_SinaCUI")
		end
	elseif args == "perf" then
		local infos = PerformanceCounter:Get("Healium_Core")
		if infos then
			Dump(0, nil, infos)
			DumpSack:Flush("Healium_SinaCUI")
		end
	elseif args == "show" then
		DumpSack:Show()
	else
		local infos = H:DumpInformation()
		local found = false
		if infos and infos.Units then
			for _, unitInfo in pairs(infos.Units) do
				if unitInfo.Unit == arg1 or unitInfo.Unitname == arg1 then
					Dump(0, nil, unitInfo)
					found = true
				end
			end
		end
		if found then
			DumpSack:Flush("Healium_SinaCUI")
		else
			print(L.healium_CONSOLE_DUMP_UNITNOTFOUND)
		end
	end
end

local function SlashHandlerReset(args)
	if args == "perf" then
		PerformanceCounter:Reset("Healium_Core")
		LastPerformanceCounterReset = GetTime()
		print(L.healium_CONSOLE_RESET_PERF)
	end
end

local function SlashHandlerToggle(args)
	if InCombatLockdown() then
		print(L.healium_NOTINCOMBAT)
		return
	end
	if args == "raid" then
		ToggleHeader(PlayerRaidHeader)
	elseif args == "tank" then
		ToggleHeader(TankRaidHeader)
	elseif args == "pet" then
		ToggleHeader(PetRaidHeader)
	else
		print(L.healium_CONSOLE_TOGGLE_INVALID)
	end
end

SlashCmdList["HLMT"] = function(cmd)
	local switch = cmd:match("([^ ]+)")
	local args = cmd:match("[^ ]+ (.+)")
	if switch == "dump" then
		SlashHandlerDump(args)
	elseif switch == "reset" then
		SlashHandlerReset(args)
	elseif switch == "toggle" then
		SlashHandlerToggle(args)
	else
		SlashHandlerShowHelp()
	end
end
