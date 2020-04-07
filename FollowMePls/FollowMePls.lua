
SLASH_FMP1 = "/fmp"

local loaded = false

-- Handle slash commands
SlashCmdList["FMP"] = function(msg)
	
	if not loaded then return end
	
	if msg == "enabled" then
		print("enabled: " .. FMP_ENABLED)
		return
	end
	
	if msg == "partyonly" then
		print("partyonly: " .. FMP_PARTY_ONLY)
		return
	end
	
	if msg == "msg" then
		print("msg: " .. FMP_MSG)
		return
	end
	
	if msg == "enabled 1" then
		print("FollowMePls enabled.")
		FMP_ENABLED = 1
		return
	end
	
	if msg == "enabled 0" then
		print("FollowMePls disabled.")
		FMP_ENABLED = 0
		return
	end
	
	if msg == "partyonly 1" then
		print("Only party and raid members can make you follow.")
		FMP_PARTY_ONLY = 1
		return
	end
	
	if msg == "partyonly 0" then
		print("Anyone can make you follow.")
		FMP_PARTY_ONLY = 0
		return
	end
	
	if msg == "msg 1" then
		print("The login message will show.")
		FMP_MSG = 1
		return
	end
	
	if msg == "msg 0" then
		print("The login message will not show anymore.")
		FMP_MSG = 0
		return
	end
	
	print("* FollowMePls Commands:")
	print("* /fmp enabled 1/0 - 1 to enable and 0 to disable the addon")
	print("* /fmp partyonly 1/0 - 1 to only accept follow commands from party and raid members, 0 to accept from anybody")
	print("* /fmp msg 1/0 - 1 to show the login message, 0 to not show")
end

-- Set up our frame
local frame = CreateFrame("Frame", "FollowMePlsFrame")
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:RegisterEvent("ADDON_LOADED")

-- Handle events
frame:SetScript("OnEvent", function(self, event, ...)

	if event == "ADDON_LOADED" then
		local arg1 = ...
		
		if arg1 == "FollowMePls" then
			
			if FMP_ENABLED == nil then
				FMP_ENABLED = 1
			end
			
			if FMP_PARTY_ONLY == nil then
				FMP_PARTY_ONLY = 1
			end
			
			if FMP_MSG == nil then
				FMP_MSG = 1
			end
			
			if FMP_MSG == 1 then
				print("* FollowMePls loaded.")
				print("* Type /fmp to see commands.")
				print("* Source: github.com/techiew/FollowMePls")
			end
			
			loaded = true
		end
		
		return
	end
			
	local text, playerName = ...
	
	if event == "CHAT_MSG_WHISPER" and text == "!follow" then
		local name = playerName
		local i, j = string.find(name, '-')
		name = string.sub(name, 0, j - 1)
		
		if FMP_ENABLED == 0 then 
			print("Can't auto-follow, FollowMePls is disabled.")
			return 
		end
		
		if FMP_PARTY_ONLY == 0 then
			print("Now following " .. name .. ".")
			FollowUnit(name)
		elseif UnitInParty(name) or UnitInRaid(name) ~= nil then 
			FollowUnit(name)
			print("Now following " .. name .. ".")
			if FMP_MSG == 1 then
				SendChatMessage("Now following you", "WHISPER", nil, name)
			end
		else
			print("Can't auto-follow " .. name .. ", not in party or raid.")
		end
		
	end
	
end)
