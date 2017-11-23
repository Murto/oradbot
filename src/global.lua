local global = global or nil


if (not global) then
	global = {}
	global.config_path = "oradbot.conf"
	global.about_path = "about.md"
	global.help_path = "help.md"
end


return global
