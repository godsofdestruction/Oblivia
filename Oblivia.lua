--[[
Oblivia v0.2-alpha
Game monitor for World of Warcraft Wrath of The Lich King expansion, version 3.3.5 revision 30300
Creation Date : 01/03/2018
Creator : Oblivia
--------------------------------------------------------------------------------------------------
TODO:
Need to figure out some kind of bot ban system, for example if person is blacklisted, and he attempts to join raid group, bot immediatelly kicks person out and warns whole raid group the reason he's banned.
Fix known bugs.





KNOWN BUGS:
!boss11 triggers !boss1 so therefore 2 raid warnings are given. Need to think out better system than string.match




]]--

--8 Ball possible answer array.
local EightBall = {
--Ten of the possible answers are affirmative.
"It is certain",
"It is decidedly so",
"Without a doubt",
"Definitelly yes!",
"You may rely on it",
"As I see it, yes",
"Most likely",
"Outlook good",
"Yep",
"Signs point to yes.",
-- Five of possible answers are non-committal.
"Reply hazy try again",
"Ask again later",
"Better not tell you now",
"Cannot predict now",
"Concentrate and ask again",
-- Five of possible answers are negative.
"Don't count on it.",
"My reply is no.",
"My sources say no.",
"Very doubtful.",
"Nop."
 }
-- 8 BALL END
local ipairs = ipairs
local strmatch = string.match

Oblivia = CreateFrame("Frame")
Oblivia:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local debugf = tekDebug and tekDebug:GetFrame("Oblivia")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end


-- check if a player is a friend. (####Future reserved####)
local function IsFriend(name)
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then
			return true
		end
	end
	return false
end
-- Check if a player is from the guild.
local function IsGuildMember(name)
	for i = 1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then
			return true
		end
	end
	return false
end
-- Register events on login to server.


-- Auto invite handler.
function Oblivia:PARTY_INVITE_REQUEST(event, sender)
-- Don't auto accept if we're in a queue
	local mode, submode = GetLFGMode();
	if ( mode ) then
		if ( mode == "queued" or mode == "listed" or mode == "rolecheck" ) then
			return
		end
	end
-- Auto-accept invites from guildies or friends but only when not in LFG queue
	if (IsFriend(sender) or IsGuildMember(sender)) and mode ~= 'queued' and mode ~= 'rolecheck' then
		local frame = StaticPopup_FindVisible("PARTY_INVITE")
		if frame then
				frame.inviteAccepted = true
				AcceptGroup()
				frame:Hide()
				SendChatMessage("Hey! type !help for more information!", "PARTY", "common", sender);
		end
	end
end

-- internal patches
function Oblivia:PLAYER_QUITING()
	-- Hide that annoying "Are you sure you want to Quit?" dialog
	StaticPopup_Hide("QUIT")
	ForceQuit()
end
if IsLoggedIn() then Oblivia:PLAYER_LOGIN() else Oblivia:RegisterEvent("PLAYER_LOGIN") end




-- Guild chat functions.
local function GuildChatFilter(self, event, arg1, msg, author,...)
	if arg1:match("!time") then
		hour,minute = GetGameTime();
		SendChatMessage("The server time is " .. hour .. ":" .. minute .. " GMT on Icecrown realm.", "GUILD", "common", author);
	end
	if arg1:match("!date") then
		SendChatMessage("The date is " .. date("%d/%m/%y %H:%M:%S"), "GUILD", "common", author);
	end
-- For test purposes
	if arg1:match("!ping") then
		SendChatMessage("pong!", "GUILD", "common", author);
	end
		if arg1:match("!hi") then
		SendChatMessage("Hey there!", "GUILD", "common", author);
	end
	if arg1:match("good bot") then
		SendChatMessage("Thank you :3", "GUILD", "common", author);
	end
-- debug end --
	if arg1:match("!help") then
		SendChatMessage("All available commands (starts with !) : time, date, ping, sex, 8ball, about, help .", "GUILD", "common", author);
	end
	if arg1:match("!sex") then
		local result = {}
			for i=1,1 do -- N here, e.g 3 if you want 3 elements
				result[i] = math.random(#SexJokeTable)
			end
		SendChatMessage(table.concat(result,", "), "GUILD", "common", author);
	end
	if arg1:match("8ball") then
		local num = tostring(GetTime())
				num = math.random(#EightBall)
				SendChatMessage(EightBall[num], "GUILD")
	end
	if arg1:match("!about") then
	SendChatMessage("Hey! I am Orionia, and my purpose is to help you! Use me right, and I'll be great helper for guild! Type help for commands!", "GUILD", "common", author);
	end
end

-- Raid Helper.
local function RaidChatFilter(self, event, arg1, arg2, msg, author, isAssistant, ...)
	if arg1:match("!raidrules") then
		SendChatMessage("Raid Rules:", "RAID", "common", author);
		SendChatMessage("1. No flaming.", "RAID", "common", author);
	    SendChatMessage("2. Don't be toxic.", "RAID", "common", author);
		SendChatMessage("3. Wipes happen. don't ragequit immediatelly.", "RAID", "common", author);
		SendChatMessage("4. Rolls going over priority, MS>OS>VENDOR/Disenchant", "RAID", "common", author);
	    SendChatMessage("Have fun!", "RAID", "common", author);
	end
	
	-- Icecrown Citadel 10/25 man normal mode tactics.
	if arg1:match("!boss1") and IsRaidOfficer("Orionia") == 1 then
	SendChatMessage("Tanks stack up, Raid stacks up, dodge flames, dps boss, dps spikes when they come up, run away and spread out for bonestorm. Rinse and repeat.", "RAID_WARNING", "common", author);
	elseif IsRaidOfficer("Orionia") == 0 then
	SendChatMessage("ERROR : I cannot explain tactics as I am not an assistant. Please make sure to set Assistant on me and put me in Group 8.", "RAID", "common", author)
	end
	if arg1:match("!boss2") then
	SendChatMessage("DPS boss' mana shield down, kill adds when they come up, back to mana shield. Time breaking of shield to be well before adds spawn. After that, rotate tanks at 3-5 stacks, dodge ghosts, watch threat.", "RAID_WARNING", "common", author);
	end
	
	if arg1:match("!boss3") then
	SendChatMessage("Press 1 and 2 in cannons, shoot some adds, jump over to kill some mage when your cannons get frozen,jump back when she's dead. rinse and repeat.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss4") then
	SendChatMessage("Burn that fat test dummy, when little red creatures spawn kill them first, then switch back to boss.Heal up those that get motfc, etcetc.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss5") then
	SendChatMessage("Shoot boss, dodge slime spray, run to the offtank when you get the debuff, move out of centre when explosion happens. rinse and repeat.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss6") then
	SendChatMessage("DPS check + tank/healer Cooldowns rotation test. Spread out in room, DPS boss, stack up in 3 groups for spores (2 in ranged 1 in melee/tank) Rinse and repeat.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss7") then
	SendChatMessage("PP Tactics : DPS boss, switch to oozes when they spawn, rinse and repeat. Dodge stuff in phase 2. burn hard in phase 3.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss8") then
	SendChatMessage("BPC Tactics: 3 different princes take turns to become more powerful. Spread out for lightning boss, run away from big fireballs for fire boss, keep the OT up for shadow boss. Switch bosses when neccesary.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss9") then
	SendChatMessage("BQL Tactics: Get a bite order down, carry it out, run to middle for link, run to the side for shadows, spread out for air phase.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss10") then
	SendChatMessage("Valithria Tactics: Kill adds in priority order, healers enter portal and win.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss11") then
	SendChatMessage("Sindragosa Tactics: Dont let your stacks go up too high. LoS bombs. Alternate tombs left and right and win.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!boss12") then
	SendChatMessage("DPS check + tank/healer Cooldowns rotation test. Spread out in room, DPS boss, stack up in 3 groups for spores (2 in ranged 1 in melee/tank) Rinse and repeat.", "RAID_WARNING", "common", author);
	end
	if arg1:match("!raidhelp") then
	SendChatMessage("Available commands (starts with !) : boss1-12, raidrules, raidhelp, about", "RAID", "common", author);
	end

end

function Oblivia:PLAYER_LOGIN()
	LibStub("tekKonfig-AboutPanel").new(nil, "Oblivia")

-- Event handlers
	self:RegisterEvent("PLAYER_DEAD") -- PvP repop
	self:RegisterEvent("PARTY_INVITE_REQUEST") -- Accept group invites from friends and guildies
	self:RegisterEvent("PLAYER_QUITING") -- No more "Are you sure you wanna quit?" dialog
  ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", RaidChatFilter)
  ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", GuildChatFilter)  -- In raid mode, respond ONLY to Raid Leader calls.
--[[ Show/hide player nameplates when entering/leaving combat
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
]]--

-- Skip vendor gossip code
	self:RegisterEvent("GOSSIP_SHOW")

-- The ultimate duel disable... 
	UIParent:UnregisterEvent("DUEL_REQUESTED")
end