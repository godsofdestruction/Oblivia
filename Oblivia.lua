--[[
Oblivia v0.2-alpha
Game monitor for World of Warcraft Wrath of The Lich King expansion, version 3.3.5 revision 30300
Creation Date : 01/03/2018
Creator : Oblivia
--------------------------------------------------------------------------------------------------
TODO:



KNOWN BUGS:





]]--




Oblivia = CreateFrame("Frame")
Oblivia:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)

local debugf = tekDebug and tekDebug:GetFrame("Oblivia")
local function Debug(...) if debugf then debugf:AddMessage(string.join(", ", ...)) end end

local function IsFriend(name)
	for i = 1, GetNumFriends() do
		if GetFriendInfo(i) == name then
			return true
		end
	end
	return false
end

local function IsGuildMember(name)
	for i = 1, GetNumGuildMembers() do
		if GetGuildRosterInfo(i) == name then
			return true
		end
	end
	return false
end

function Oblivia:PLAYER_LOGIN()
	LibStub("tekKonfig-AboutPanel").new(nil, "Oblivia")

	-- Event handlers
	self:RegisterEvent("PLAYER_DEAD") -- PvP repop
	self:RegisterEvent("PARTY_INVITE_REQUEST") -- Accept group invites from friends and guildies
	self:RegisterEvent("PLAYER_QUITING") -- No more "Are you sure you wanna quit?" dialog

	-- Show/hide player nameplates when entering/leaving combat
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	-- Skip vendor gossip code
	self:RegisterEvent("GOSSIP_SHOW")

	-- The ultimate duel disable... 
	UIParent:UnregisterEvent("DUEL_REQUESTED")
end

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