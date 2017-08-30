local config = require("config")
local discordia = require("discordia")
local matchmaker = require("matchmaker")
local utility = require("utility")
local client = discordia.Client()

local admins = {}
local config_path = "oradbot.conf"

function add_admin(p_user)
	if (not p_user) then
		return false, "User must be given."
	elseif (admins[p_user]) then
		return false, "User is already an admin."
	end
	admins[p_user] = true
	return true
end

function remove_admin(p_user)
	if (not p_user) then
		return false, "User must be given."
	elseif (not admins[p_user]) then
		return false, "User is not an admin."
	end
	admins[p_user] = nil
	return true
end

client:on("ready", function()
	print("Logged in as " .. client.user.username)
	local options = config.read("oradbot.conf")
	if (not options) then
		print("[!] Could not load config.")
		return
	end
	print("[*] Loading config...")
	if (options["ADMINS"]) then
		admins = utility.to_set(options["ADMINS"])
		print("[*] ADMINS set to:", table.unpack(options["ADMINS"]))
	end
	if (options["MOD_TYPES"]) then
		matchmaker.mod_types = utility.to_set(options["MOD_TYPES"])
		print("[*] MOD_TYPES set to:", table.unpack(options["MOD_TYPES"]))
	end
	if (options["GAME_TYPES"]) then
		matchmaker.game_types = utility.to_set(options["GAME_TYPES"])
		print("[*] GAME_TYPES set to:", table.unpack(options["GAME_TYPES"]))
	end
	print("[*] Loaded config.")
end)

client:on("messageCreate", function(p_message)
	local name = p_message.author.username
	local command = utility.split(p_message.content:lower())
	if (command[1] == "!wait") then
		local status, reason = matchmaker.add_waiting(p_message.author, command[2], command[3], command[4] and tonumber(command[4]))
		if (status) then
			print("[*] Added " .. name .. " to the waiting list.")
			p_message:reply("You have been added to the waiting list.")
		else
			print("[!] Failed to add " .. name .. " to the waiting list.")
			p_message:reply("You could not be added to the waiting list.\nReason: " .. reason)
		end
	elseif (command[1] == "!play") then
		local status, reason = matchmaker.remove_waiting(p_message.author)
		if (status) then
			print("[*] Removed " .. name .. " from the waiting list.")
			p_message:reply("You have been removed from the waiting list.")
		else
			print("[!] Failed to remove " .. name .. " from the waiting list.")
			p_message:reply("You could not be removed from the waiting list.\nReason: " .. reason)
		end
	elseif (command[1] == "!announce") then
		local status, reason = matchmaker.announce(p_message.author, command[2], command[3], command[4])
		if (status) then
			print("[*] Announced " .. name .. "'s game.")
			p_message:reply("Your game has been announced.")
		else
			print("[!] Failed to announce " .. name .. "'s game.")
			p_message:reply("Your game could not be announced.\nReason: " .. reason)
		end
	elseif (command[1] == "!list") then
		print("[*] Listing all waiting players.")
		p_message:reply(matchmaker.to_string())
	elseif (command[1] == "!help") then
		print("[*] Printing help.")
		local file, reason = io.open("help.txt")
		if (file) then
			p_message:reply(file:read("*all"))
			file:close()
		else
			print("[!] " .. reason)
			p_message:reply("Could not get help.\nReason: " .. reason)
		end
	elseif (command[1] == "!mod_types") then
		print("[*] Printing mod_types.")
		local str = ""
		for v, _ in pairs(matchmaker.mod_types) do
			str = str .. " " .. v
		end
		p_message:reply("Mod types:" .. str)
	elseif (command[1] == "!game_types") then
		print("[*] Printing game_types.")
		local str = ""
		for v, _ in pairs(matchmaker.game_types) do
			str = str .. " " .. v
		end
		p_message:reply("Game types:" .. str)
	elseif (admins[name]) then
		if (command[1] == "!quit") then
			print("[*] Stopping bot...")
			p_message:reply("See you next time...")
			client:stop()
		elseif (command[1] == "!add") then
			if (command[2] == "mod_type") then
				local status, reason = matchmaker.add_mod_type(command[3])
				if (status) then
					print("[*] mod_type added.")
					p_message:reply("The mod_type was added.")
				else
					print("[!] mod_type could not be added.")
					p_message:reply("The mod_type could not be added.\nReason: " .. reason)
				end
			elseif (command[2] == "game_type") then
				local status, reason = matchmaker.add_game_type(command[3])
				if (status) then
					print("[*] game_type added.")
					p_message:reply("The game_type was added.")
				else
					print("[!] game_type could not be added.")
					p_message:reply("The game_type could not be added.\nReason: " .. reason)
				end
			elseif (command[2] == "admin") then
				local status, reason = add_admin(command[3])
				if (status) then
					print("[*] Admin added.")
					p_message:reply("The user was added to admins.")
				else
					print("[!] Admin could not be added.")
					p_message:reply("The user could not be added to admins.\nReason: " .. reason)
				end
			end
		elseif (command[1] == "!remove") then
			if (command[2] == "mod_type") then
				local status, reason = matchmaker.remove_mod_type(command[3])
				if (status) then
					print("[*] mod_type removed.")
					p_message:reply("The mod_type was removed.")
				else
					print("[!] mod_type could not be removed.")
					p_message:reply("The mod_type could not be removed.\nReason: " .. reason)
				end
			elseif (command[2] == "game_type") then
				local status, reason = matchmaker.remove_game_type(command[3])
				if (status) then
					print("[*] game_type removed.")
					p_message:reply("The game_type was removed.")
				else
					print("[!] game_type could not be removed.")
					p_message:reply("The game_type could not be removed.\nReason: " .. reason)
				end
			elseif (command[2] == "admin") then
				local status, reason = remove_admin(command[3])
				if (status) then
					print("[*] Admin removed.")
					p_message:reply("The user was removed from admins.")
				else
					print("[!] Admin could not be removed.")
					p_message:reply("The user could not be removed from admins.\nReason: " .. reason)
				end
			end
		elseif (command[1] == "!save") then
			local options = {
					["ADMINS"]		= utility.to_array(admins),
					["MOD_TYPES"]	= utility.to_array(matchmaker.mod_types),
					["GAME_TYPES"]	= utility.to_array(matchmaker.game_types)
				}
			config.write(config_path, options)
			print("[*] Config saved.")
		elseif (command[1] == "!reset") then
			config.read(config_path)
			print("[*] Config reset.")
		end
	end
end)


--	Main code

local token = args[2] or error("No token passed.")
print("Using token: " .. args[2])
client:run(token)
