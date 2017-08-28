local discordia = require("discordia")
local matchmaker = require("matchmaker")
local utility = require("utility")
local client = discordia.Client()

client:on("ready", function()
	print("Logged in as " .. client.user.username)
end)

client:on("messageCreate", function(p_message)
	local name = p_message.author.username
	local command = utility.split_command(p_message.content:lower())
	if (command[1] == "!quit") then
		if (name == "Murto") then
			print("[*] Stopping bot...")
			p_message:reply("Bye bye!")
			client:stop(true)
		else
			print("[!] Failed to stop bot.")
			p_message:reply("I could not be stopped.\nReason: Insufficient permissions.")
		end
	elseif (command[1] == "!wait") then
		local status, reason = matchmaker.add_waiting(p_message.author, command[2], command[3] and tonumber(command[3]))
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
		local status, reason = matchmaker.announce(p_message.author, command[2], command[3])
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
		p_message:reply("Possible commands:\n\
**!wait (1v1|team|mini|any) [timeout]**   -   Wait for a game of the given type until timeout minutes have passed. If timeout is not given then wait forever.\n\n**!play**   -   Remove yourself from the waiting list.\n\n**!announce (1v1|team|mini) [description]**   -   Announce a game of the given type with the given description. A description is optional.\n\n**!list**   -   List the current waiting players.\n\n**!help**   -   Display this.")
	elseif (command[1]:byte() == string.byte("!")) then
		print("[!] Unknown command.")
		p_message:reply("Unknown command.\nUse !help to list possible commands.")
	end
end)


--	Main code

local token = args[2] or error("No token passed.")
print("Using token: " .. args[2])
client:run(token)
