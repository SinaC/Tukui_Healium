local ADDON_NAME, ns = ...
local L = ns.Locales

if GetLocale() == "frFR" then
	L.COMMANDS_HELP_USE = "Utilisez %s ou %s pour configurer TukuiHealium"
	L.COMMANDS_HELP_TOGGLE = "%s toggle - active/d\195\169sactive l'affichage des fen\195\170tres de raid"
	L.COMMANDS_HELP_SHOW = "%s show - active l'affichage des fen\195\170tres de raid"
	L.COMMANDS_HELP_HIDE = "%s hide - d\195\169sactive l'affichage des fen\195\170tres de raid"
	L.ERROR_NOTINCOMBAT = "Impossible pendant un combat!!!"
	L.ERROR_ALREADYSHOWN = "Les fen\195\170tres de raid sont d\195\169j\195\160 affich\195\169es"
	L.ERROR_ALREADYHIDDEN = "Les fen\195\170tres de raid sont d\195\169j\195\160 cach\195\169es"
	L.INFO_SHOW = "Fen\195\170tres de raid affich\195\169es. Pour les cacher, utilisez %s toggle ou le tabmenu/minimap"
	L.INFO_HIDE = "Fen\195\170tres de raid cach\195\169es. Pour les afficher, utilisez %s toggle ou le tabmenu/minimap"
	L.INFO_GLOBALLYDISABLED = "TukuiHealium d\195\169sactiv\195\169. Utilisez le tabmenu ou la minimap pour le r\195\169activer"
	L.GREETING_VERSION = "|cffC495DDTukuiHealium|r version %s + HealiumCore version %s"
	L.GREETING_VERSIONUNKNOWN = "|cffC495DDTukuiHealium|r version %s + version inconnue of HealiumCore"
end