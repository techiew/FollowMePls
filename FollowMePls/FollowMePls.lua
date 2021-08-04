
SLASH_FMP1 = "/fmp"
SLASH_FMP2 = "/followmepls"

local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)
local AUTO, GROUND, FLYING, UNDERWATER, WATERWALK, YAK, MAMMOTH, BRUTO = 0, 1, 2, 3, 4, 5, 6, 7

-- These variables and functions are used for print() text formatting.
local line = "|c002F2F2A---------------------------------------------|r"
local pre = "|c002F2F2A*|r   "
local sep = " |c00FFFFFF-|r "
local retailOnly = " |c00C2C5CC(RETAIL ONLY)|r"

local function header(text)
	return "|c00F9858B" .. text .. "|r"
end

local function subj(text)
	return "|c00F9858B" .. text .. "|r"
end

local function desc(text)
	return "|c00FFFFFF" .. text .. "|r"
end
--

-- Handle slash commands
SlashCmdList["FMP"] = function(msg)
		
	msg = string.lower(msg)
		
	if msg == "0" then
		print("FollowMePls disabled.")
		FMP_ENABLED = 0
		return
	end
	
	if msg == "1" then
		print("FollowMePls enabled.")
		FMP_ENABLED = 1
		return
	end
		
	if msg == "group 0" then
		print("Now anyone can make you follow.")
		FMP_GROUP_ONLY = 0
		return
	end
	
	if msg == "group 1" then
		print("Now only party and raid members can make you follow.")
		FMP_GROUP_ONLY = 1
		return
	end
	
	if msg == "whispers" then
		print(line)
		print(pre .. header("FollowMePls Whisper Commands:"))
		print(pre .. subj("!follow") .. sep .. desc("Makes the character follow you, simply '!f' works too."))
		print(pre .. subj("!stop") .. sep .. desc("Makes the character stop following you, simply '!s' works too."))
		print(pre .. subj("!mount") .. sep .. desc("Makes the character summon a random mount, simply '!m' works too. Favorited mounts are prioritized.") .. retailOnly)
		print(pre .. subj("!waterwalk") .. sep .. desc("Makes the character summon a random mount that can walk on water.") .. retailOnly)
		print(pre .. subj("!yak") .. sep .. desc("Makes the character summon the 'Grand Expedition Yak' mount.") .. retailOnly)
		print(pre .. subj("!mammoth") .. sep .. desc("Makes the character summon the 'Traveler's Tundra Mammoth' mount.") .. retailOnly)
		print(pre .. subj("!bruto") .. sep .. desc("Makes the character summon the 'Mighty Caravan Brutosaur' mount.") .. retailOnly)
		print(pre .. subj("!dismount") .. sep .. desc("Makes the character dismount, simply '!d' works too.") .. retailOnly)
		return
	end
	
	if msg == "msg" then
	
		if FMP_MSG == 0 then
			print("The login message will show.")
			FMP_MSG = 1
		else
			print("The login message will not show anymore.")
			FMP_MSG = 0
		end

		return
	end
	
	if msg == "enabled" then
		print("'enabled' is set to: " .. FMP_ENABLED)
		return
	end
	
	if msg == "group" then
		print("'group' is set to: " .. FMP_GROUP_ONLY)
		return
	end
	
	if msg == "loginmsg" then
		print("'msg' is set to: " .. FMP_MSG)
		return
	end
	
	print(line)
	print(pre .. header("FollowMePls Commands:"))
	print(pre .. subj("/fmp 1/0") .. sep .. desc("1 = Enable the addon, 0 = Disable the addon."))
	print(pre .. subj("/fmp group 1/0") .. sep .. desc("1 = Only accept follow commands from party and raid members, 0 = Accept from anybody."))
	print(pre .. subj("/fmp whispers") .. sep .. desc("See the list of possible whisper commands."))
	print(pre .. subj("/fmp msg") .. sep .. desc("Toggles the login message."))
end  

-- Finds a suitable mount of the requested mountType and then summons it
local function SummonMount(mountType)

	if isClassic then
		print("Cannot mount, auto-mounting only works in retail.")
		return false
	end
		
	if IsFlying() then return false end
		
	if mountType == AUTO then
		mountType = GROUND
		if IsFlyableArea() then mountType = FLYING end
		if IsSwimming() then mountType = UNDERWATER end
	end
		
	local mounts = C_MountJournal.GetMountIDs()
	local suitableMounts = {}
	local favoritedSuitableMounts = {}
	
	for key, value in pairs(mounts) do
		local creatureName, spellID, icon, active, 
			isUsable, sourceType, isFavorite, isFactionSpecific, 
			faction, hideOnChar, isCollected, mountID = C_MountJournal.GetMountInfoByID(value) 
			
		local suitableMount = nil
			
		if isCollected and isUsable then 
			local creatureDisplayInfoID, description, source, isSelfMount,
				mountTypeID, uiModelSceneID, animID, spellVisualKitID, 
				disablePlayerMountPreview = C_MountJournal.GetMountInfoExtraByID(value)
			
			if mountType == GROUND then
			
				if mountTypeID == 230 then
					suitableMount = value
				end
				
			elseif mountType == FLYING then
				
				if mountTypeID == 248 then
					suitableMount = value
				end
				
			elseif mountType == UNDERWATER then
			
				if mountTypeID == 231 or mountTypeID == 254 then
					suitableMount = value
				end
			
			elseif mountType == WATERWALK then
			
				if spellID == 127271 or spellID == 118089 then -- Crimson Water Strider and Azure Water Strider
					suitableMount = value
				end
			
			elseif mountType == YAK then
				
				if spellID == 122708 then -- Grand Expedition Yak
					suitableMount = value
				end
				
			elseif mountType == MAMMOTH then
				englishFaction, localizedFaction = UnitFactionGroup("player")
				
				if (spellID == 61425 and englishFaction == "Alliance") or (spellID == 61447 and englishFaction == "Horde") then -- Traveler's Tundra Mammoth
					suitableMount = value
				end
			
			elseif mountType == BRUTO then
				
				if spellID == 264058 then -- Mighty Caravan Brutosaur
					suitableMount = value
				end
				
			end
			
			if suitableMount ~= nil then
			
				if isFavorite then 
					table.insert(favoritedSuitableMounts, suitableMount)
				else
					table.insert(suitableMounts, suitableMount)
				end
				
			end
			
		end
		
	end
	
	local numNonFavorites = table.getn(suitableMounts)
	local numFavorites = table.getn(favoritedSuitableMounts)
	
	if numNonFavorites == 0 and numFavorites == 0 then
		
		if mountType == UNDERWATER then
			return SummonMount(FLYING)
		elseif mountType == FLYING then
			return SummonMount(GROUND)
		elseif mountType == YAK or mountType == MAMMOTH or mountType == BRUTO then
			print("You don't have that mount!")
			return false
		else
			print("Error: Did not find a usable mount!")
			return false
		end
		
	else

		if numFavorites == 0 then
			C_MountJournal.SummonByID(suitableMounts[math.random(1, numNonFavorites)])
		else
			C_MountJournal.SummonByID(favoritedSuitableMounts[math.random(1, numFavorites)])
		end
		
		return true
	end
	
end

local function PerformCommand(cmd, playerName)
	local commands = {
		"!follow", "!f", "!stop", "!s",
		"!mount", "!m", "!waterwalk", "!yak", 
		"!mammoth", "!bruto", "!dismount", "!d"
	}
	
	local cmdExists = false
	
	for key, value in pairs(commands) do

		if cmd == value then 
			cmdExists = true
			break
		end
		
	end
	
	if not cmdExists then return end
	
	if FMP_ENABLED == 0 then 
		print("Can't do that, FollowMePls is disabled.")
		return 
	end
	
	-- Removes realm name from player name
	local name = playerName
	local i, j = string.find(name, '-')
	
	if i ~= nil then
		name = string.sub(name, 0, j - 1)
	end
	
	if FMP_GROUP_ONLY == 1 then
	
		if UnitInParty(name) == false and UnitInRaid(name) == nil then
			print("Can't do that, " .. name .. " is not in your party or raid.")
			return false
		end
		
	end
	
	if cmd == "!follow" or cmd == "!f" then
		FollowUnit(name)
		print("Now following " .. name .. ".")
	end
	
	if cmd == "!stop" or cmd == "!s" then
		FollowUnit("player")
		print("Stopped following.")
	end
	
	if cmd == "!mount" or cmd == "!m" then	
		SummonMount(AUTO)
	end
	
	if cmd == "!waterwalk" then
		SummonMount(WATERWALK)
	end
	
	if cmd == "!yak" then		
		SummonMount(YAK)
	end
	
	if cmd == "!mammoth" then
		SummonMount(MAMMOTH)
	end
	
	if cmd == "!bruto" then
		SummonMount(BRUTO)
	end
	
	if cmd == "!dismount" or cmd == "!d" then
		
		if isClassic then
			print("This command only works in retail.")
			return
		end
	
		Dismount()
	end
	
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
			
			if FMP_GROUP_ONLY == nil then
				FMP_GROUP_ONLY = 1
			end
			
			if FMP_MSG == nil then
				FMP_MSG = 1
			end
			
			if FMP_MSG == 1 then
				print(pre .. subj("FollowMePls loaded."))
				print(pre .. subj("Type /fmp to see commands."))
				print(pre .. subj("Source: github.com/techiew/FollowMePls"))
			end
			
		end
		
	end
			
	if event == "CHAT_MSG_WHISPER" then
		local text, playerName = ...
		text = string.lower(text)
		PerformCommand(text, playerName)
	end
	
end)
