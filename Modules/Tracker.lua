---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

---@class Tracker : AceConsole-3.0, AceEvent-3.0, AceAddon
local Tracker = AceAddon:GetAddon("GoldTracker"):NewModule("Tracker", "AceConsole-3.0", "AceEvent-3.0")

function Tracker:OnInitialize()
	self.db = ns.db
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")
end

function Tracker:PLAYER_ENTERING_WORLD()
	self:PLAYER_GUILD_UPDATE()
	self:UpdateMoney()
end

function Tracker:PLAYER_GUILD_UPDATE()
	if not IsGuildLeader() then
		self:SetMoney("guildBank", 0)
	end
end

function Tracker:UpdateMoney()
	self:SetMoney("bags", GetMoney())
end

function Tracker:UpdateGuildBankMoney()
	if IsGuildLeader() then
		self:SetMoney("guildBank", GetGuildBankMoney())
	else
		self:SetMoney("guildBank", 0)
	end
end

function Tracker:SetMoney(source, amount)
	local name = UnitName("player")
	local realm = GetNormalizedRealmName()
	local player = string.format("%s-%s", name, realm)
	local db = self.db.global
	if not db.characterSnapshots[player] then
		db.characterSnapshots[player] = {
			sources = {},
		}
	end
	self.db.global.characterSnapshots[player].sources[source] = {
		amount = amount,
		lastUpdate = time(),
	}
end
