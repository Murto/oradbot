local global = global or nil


if (not global) then
	global = {}
	global.config_path = "oradbot.conf"
	global.about_path = "about.txt"
	global.help_path = "help.txt"
end


return global
