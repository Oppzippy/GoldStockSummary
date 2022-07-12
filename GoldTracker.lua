local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local LibCopyPaste = LibStub("LibCopyPaste-1.0")

local Core = AceAddon:NewAddon("GoldTracker", "AceConsole-3.0", "AceEvent-3.0")
---@class GoldTrackerCore : AceConsole-3.0, AceEvent-3.0, AceAddon
---@cast Core GoldTrackerCore

local dbDefaults = {
	global = {
		characterCopper = {},
		characterLastUpdate = {},
	}
}

function Core:OnInitialize()
	self.db = AceDB:New("GoldTrackerDB", dbDefaults, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_GUILD_UPDATE")
	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")

	self:RegisterChatCommand("goldtracker", "SlashCommand")
end

function Core:SlashCommand(args)
	if args == "realm" or args == "" then
		LibCopyPaste:Copy("Gold Tracker", self:GetGoldByRealmCSV())
	elseif args == "character" or args == "player" then
		LibCopyPaste:Copy("Gold Tracker", self:GetGoldCSV())
	end
end

function Core:GetGoldByRealmCSV()
	local realms = {}
	for player, copperSources in next, self.db.global.characterCopper do
		local totalCopper = 0
		for _, copper in next, copperSources do
			totalCopper = totalCopper + copper
		end
		local name, realm = strsplit("-", player)
		if not realms[realm] then
			realms[realm] = {}
		end
		realms[realm].copper = (realms[realm].copper or 0) + totalCopper
		if not realms[realm].newestUpdate or realms[realm].newestUpdate < self.db.global.characterLastUpdate[player] then
			realms[realm].newestUpdate = self.db.global.characterLastUpdate[player]
		end
		if not realms[realm].oldestUpdate or realms[realm].oldestUpdate > self.db.global.characterLastUpdate[player] then
			realms[realm].oldestUpdate = self.db.global.characterLastUpdate[player]
		end
	end

	local csv = {}
	for realm, info in next, realms do
		local newestUpdate, oldestUpdate
		if info.newestUpdate then
			newestUpdate = date("%Y-%m-%d %I:%M:%S %p", info.newestUpdate)
		end
		if info.oldestUpdate then
			oldestUpdate = date("%Y-%m-%d %I:%M:%S %p", info.oldestUpdate)
		end
		csv[#csv + 1] = string.format(
			"%s,%s,%s,%s",
			realm,
			info.copper / COPPER_PER_GOLD,
			newestUpdate or "",
			oldestUpdate or ""
		)
	end
	return table.concat(csv, "\n")
end

function Core:GetGoldCSV()
	local characterCopper = {}
	for player, copperSources in next, self.db.global.characterCopper do
		local totalCopper = 0
		for _, copper in next, copperSources do
			totalCopper = totalCopper + copper
		end
		local dateTime = ""
		if self.db.global.characterLastUpdate[player] then
			dateTime = date("%Y-%m-%d %I:%M:%S %p", self.db.global.characterLastUpdate[player])
		end
		local name, realm = strsplit("-", player)
		characterCopper[#characterCopper + 1] = string.format(
			"%s,%s,%s,%s",
			realm,
			name,
			totalCopper / COPPER_PER_GOLD,
			dateTime
		)
	end
	return table.concat(characterCopper, "\n")
end

function Core:PLAYER_ENTERING_WORLD()
	self:PLAYER_GUILD_UPDATE()
	self:UpdateMoney()
end

function Core:PLAYER_GUILD_UPDATE()
	if not IsGuildLeader() then
		self:SetMoney("guildBank", 0)
	end
end

function Core:UpdateMoney()
	self:SetMoney("bags", GetMoney())
end

function Core:UpdateGuildBankMoney()
	if IsGuildLeader() then
		self:SetMoney("guildBank", GetGuildBankMoney())
	else
		self:SetMoney("guildBank", 0)
	end
end

function Core:SetMoney(source, amount)
	local name = UnitName("player")
	local realm = GetNormalizedRealmName()
	local player = string.format("%s-%s", name, realm)
	local db = self.db.global
	if not db.characterCopper[player] then
		db.characterCopper[player] = {}
	end
	if not db.characterLastUpdate[player] then
		db.characterLastUpdate[player] = {}
	end
	self.db.global.characterCopper[player][source] = amount
	self.db.global.characterLastUpdate[player] = time()
end
