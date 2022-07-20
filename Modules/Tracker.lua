---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

---@class Tracker : AceConsole-3.0, AceEvent-3.0, AceAddon
local Tracker = AceAddon:GetAddon("GoldTracker"):NewModule("Tracker", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")

function Tracker:OnInitialize()
	self.db = ns.db
end

function Tracker:OnEnable()
	self:UpdateFaction()
	self:UpdateMoney()

	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")

	-- These events can fire many times quickly. No point in repeatedly updating the same thing.
	self:RegisterBucketEvent("GUILD_RANKS_UPDATE", 1, "UpdateOwner")
	self:RegisterBucketEvent("PLAYER_GUILD_UPDATE", 1, "UpdateGuildAndOwner")

	C_Timer.After(0, function()
		-- GetGuildInfo will return nil until PLAYER_GUILD_UPDATE fires, but it's inconsistent and doesn't always fire when logging in.
		-- It seems to always be ready by the first frame, so we can just wait until then.
		-- TODO switch to https://wowpedia.fandom.com/wiki/FIRST_FRAME_RENDERED if classic supports it
		self.isFirstFrameRendered = true
		self:UpdateGuildAndOwner()
	end)
end

function Tracker:IsInBrokenState()
	-- When events fire, these functions can return conflicting information.
	if IsInGuild() then
		return GetGuildInfo("player") == nil or GetNumGuildMembers() == 0
	else
		return GetGuildInfo("player") ~= nil or GetNumGuildMembers() ~= 0
	end
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

function Tracker:UpdateGuildAndOwner()
	if self:IsInBrokenState() then
		C_Timer.After(1, function()
			self:UpdateGuildAndOwner()
		end)
	end

	local character = self:GetCharacter()
	character.guild = IsInGuild() and self:GetGuildNameAndRealm() or nil
	self:UpdateOwner()
end

function Tracker:UpdateOwner()
	if self:IsInBrokenState() then
		C_Timer.After(1, function()
			self:UpdateOwner()
		end)
	end

	if IsInGuild() then
		local guild = self:GetGuild()
		guild.owner = self:GetGuildOwner()
	end
end

function Tracker:UpdateGuildBankMoney()
	if IsInGuild() then
		local guild = self:GetGuild()
		guild.copper = GetGuildBankMoney()
	end
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
