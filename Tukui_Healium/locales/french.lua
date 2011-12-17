local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales

if GetLocale() == "frFR" then
	L.healium_DISABLE_OLDVERSION = "Un conflit avec une vieille version a \195\169t\195\169 d\195\169tect\195\169. Cliquez sur OK pour recharger l'interface"

	L.healium_NOTINCOMBAT = "Impossible en combat"

	L.healium_GREETING_VERSIONUNKNOWN = "Num\195\169ro de version non-disponible"
	L.healium_GREETING_VERSION = "Healium Core version %s"
	L.healium_GREETING_OPTIONS = "Utilisez /thlm pour obtenir une liste des commandes"

	L.healium_CONSOLE_HELP_GENERAL =        "Commandes pour /thlm"
	L.healium_CONSOLE_HELP_DUMPGENERAL =    " dump - affiche les informations \195\160 propos des fen\195\170tres Healium visible"
	L.healium_CONSOLE_HELP_DUMPFULL =       " dump full - affiche les informations \195\160 propos des toutes les fen\195\170tres Healium"
	L.healium_CONSOLE_HELP_DUMPUNIT =       " dump [unit] - affiche les informations \195\160 propos d'une unit\195\169"
	L.healium_CONSOLE_HELP_DUMPPERF =       " dump perf - affiche les compteurs de performance"
	L.healium_CONSOLE_HELP_DUMPSHOW =       " dump show - affiche la fen\195\170tre de dump"
	L.healium_CONSOLE_HELP_RESETPERF =      " reset perf - remet \195\160 z\195\169ro les compteurs de performance"
	L.healium_CONSOLE_HELP_TOGGLE =         " toggle raid||tank|pet - affiche ou cache une fen\195\170tre"
	L.healium_CONSOLE_DEBUG_ENABLED = "Mode debug activ\195\169"
	L.healium_CONSOLE_DEBUG_DISABLED = "Mode release activ\195\169"
	L.healium_CONSOLE_DUMP_UNITNOTFOUND = "Fen\195\170tre pour l'unit\195\169 %s introuvable"
	L.healium_CONSOLE_RESET_PERF = "Les compteurs de performance ont \195\169t\195\169 remis \195\160 z\195\169ro"
	L.healium_CONSOLE_REFRESH_NOTINCOMBAT = "Impossible durant un combat"
	L.healium_CONSOLE_REFRESH_OK = "Fen\195\170tres Healium r\195\169initialis\195\169es"
	L.healium_CONSOLE_TOGGLE_INVALID = "Choix valide: raid|tank|pet|namelist"
end
