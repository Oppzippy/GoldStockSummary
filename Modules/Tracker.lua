---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

---@class Tracker : AceConsole-3.0, AceEvent-3.0, AceAddon
local Tracker = AceAddon:GetAddon("GoldTracker"):NewModule("Tracker", "AceConsole-3.0", "AceEvent-3.0")

function Tracker:OnInitialize()
	self.db = ns.db
end

function Tracker:OnEnable()
	self:UpdateFaction()
	self:UpdateMoney()
	self:UpdateGuild()
	self:UpdateGuildOwner()

	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuild")
	self:RegisterEvent("GUILD_RANKS_UPDATE", "UpdateGuildOwner")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")
end

function Tracker:UpdateFaction()
	local character = self:GetCharacter()
	local faction = UnitFactionGroup("player")
	character.faction = faction and faction:lower() or "neutral"
end

function Tracker:UpdateMoney()
	local character = self:GetCharacter()
	character.copper = GetMoney()
	character.lastUpdate = time()
end

function Tracker:UpdateGuildBankMoney()
	if IsInGuild() then
		local guild = self:GetGuild()
		guild.copper = GetGuildBankMoney()
	end
end

function Tracker:UpdateGuild()
	local character = self:GetCharacter()
	if IsInGuild() then
		character.guild = self:GetGuildNameAndRealm()
	else
		character.guild = nil
	end
end

function Tracker:UpdateGuildOwner()
	if not IsInGuild() then return end
	local guild = self:GetGuild()
	guild.owner = self:GetGuildOwner()
end

---@return string
function Tracker:GetGuildOwner()
	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex = GetGuildRosterInfo(i)
		if rankIndex == 0 then
			return name
		end
	end
	error(string.format("Unable to determine guild owner: %d members", (GetNumGuildMembers())))
end

---@return TrackedCharacter
function Tracker:GetCharacter()
	local nameAndRealm = self:GetCharacterNameAndRealm()
	local db = self.db.global
	if not db.characters[nameAndRealm] then
		db.characters[nameAndRealm] = {}
	end
	return db.characters[nameAndRealm]
end

---@return TrackedGuild
function Tracker:GetGuild()
	local nameAndRealm = self:GetGuildNameAndRealm()
	local db = self.db.global
	if not db.guilds[nameAndRealm] then
		db.guilds[nameAndRealm] = {}
	end
	return db.guilds[nameAndRealm]
end

function Tracker:GetCharacterNameAndRealm()
	local name = UnitName("player")
	local realm = GetRealmName()
	return string.format("%s-%s", name, realm)
end

function Tracker:GetGuildNameAndRealm()
	local guildName, _, _, guildRealm = GetGuildInfo("player")
	if not guildRealm then
		guildRealm = GetRealmName()
	end
	return string.format("%s-%s", guildName, guildRealm)
end
