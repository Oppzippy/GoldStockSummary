---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

---@class Tracker : AceConsole-3.0, AceEvent-3.0, AceAddon
local Tracker = AceAddon:GetAddon("GoldTracker"):NewModule("Tracker", "AceConsole-3.0", "AceEvent-3.0")

function Tracker:OnInitialize()
	self.db = ns.db
	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuild")
	self:RegisterEvent("GUILD_RANKS_UPDATE", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")
end

function Tracker:OnEnable()
	self:UpdateMoney()
	self:UpdateGuild()
end

function Tracker:UpdateMoney()
	self:SetMoney(GetMoney())
end

function Tracker:UpdateGuildBankMoney()
	if IsInGuild() then
		self:SetGuildMoney(GetGuildBankMoney())
	end
end

function Tracker:UpdateGuild()
	if not IsInGuild() then return end
	local guildName, _, _, guildRealm = GetGuildInfo("player")
	if not guildRealm then
		guildRealm = GetRealmName()
	end
	local guild = string.format("%s-%s", guildName, guildRealm)

	local db = self.db.global
	if not db.guilds[guild] then
		db.guilds[guild] = {}
	end
	db.guilds[guild].owner = self:GetGuildOwner()
end

---@param copper number
function Tracker:SetMoney(copper)
	local name = UnitName("player")
	local realm = GetRealmName()
	local character = string.format("%s-%s", name, realm)
	local db = self.db.global
	if not db.characters[character] then
		db.characters[character] = {}
	end
	db.characters[character].copper = copper
	db.characters[character].lastUpdate = time()
end

---@param copper number
function Tracker:SetGuildMoney(copper)
	local guildName, _, _, guildRealm = GetGuildInfo("player")
	if not guildRealm then
		guildRealm = GetRealmName()
	end
	local guild = string.format("%s-%s", guildName, guildRealm)
	local db = self.db.global
	if not db.guilds[guild] then
		db.guilds[guild] = {}
	end
	db.guilds[guild].copper = copper
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
