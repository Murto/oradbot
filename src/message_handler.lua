local message_handler = {}
local utility = require("utility")

function message_handler.reply(p_message, p_reply)
	local status = pcall(p_message:reply(p_reply))
	if (status) then
		coloured_print("[!] Could not send message.", 33)
	end
	return status

end

function message_handler.make_embed(p_text, p_colour)
	return {embed = {description = (p_text or ""), color = (p_colour or 0x00BB00)}}
end

return message_handler
