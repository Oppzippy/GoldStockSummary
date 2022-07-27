---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")

---@class GoldStockSummary : AceConsole-3.0, AceEvent-3.0, AceAddon
local Core = AceAddon:NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")

function Core:OnInitialize()
	self.db = AceDB:New("GoldStockSummaryDB", ns.dbDefaults, true)
	ns.db = self.db

	self:RegisterMessage("GoldStockSummary_ToggleUI", "ToggleUI")
	self:RegisterMessage("GoldStockSummary_DeleteCharacter", "OnDeleteCharacter")
	self:RegisterMessage("GoldStockSummary_ExportCharacters", "OnExportCharacters")
	self:RegisterMessage("GoldStockSummary_ExportRealms", "OnExportRealms")
end

function Core:ToggleUI()
	if ns.MainUI:IsVisible() then
		ns.MainUI:Hide()
	else
		self:ShowCharacterGoldTable()
	end
end

function Core:ShowCharacterGoldTable()
	ns.MainUI:Show({
		characters = function()
			return self:CharactersGoldTable()
		end,
		realms = function()
			return self:RealmsGoldTable()
		end,
	})
end

local characterFields = { "realm", "faction", "name", "totalMoney", "personalMoney", "guildBankMoney", "lastUpdate" }
local realmFields = { "realm", "faction", "totalMoney", "personalMoney", "guildBankMoney" }

function Core:CharactersGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Characters(ns.TrackedMoney.Create(db.characters, db.guilds))
	return ns.MoneyTable.To.ScrollingTable(characterFields, moneyTable)
end

function Core:RealmsGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Realms(ns.TrackedMoney.Create(db.characters, db.guilds))
	return ns.MoneyTable.To.ScrollingTable(realmFields, moneyTable)
end

---@param nameAndRealm string
function Core:OnDeleteCharacter(_, nameAndRealm)
	self.db.global.characters[nameAndRealm] = nil
	self:SendMessage("GoldStockSummary_MoneyUpdated")
end

---@param format string
function Core:OnExportCharacters(_, format)
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Characters(ns.TrackedMoney.Create(db.characters, db.guilds))

	local output = ""
	if format == "csv" then
		output = ns.MoneyTable.To.CSV(characterFields, moneyTable)
	elseif format == "json" then
		output = ns.MoneyTable.To.JSON("characters", moneyTable)
	end

	self:SendMessage("GoldStockSummary_SetExportCharactersOutput", output)
end

function Core:OnExportRealms(_, format)
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Realms(ns.TrackedMoney.Create(db.characters, db.guilds))

	local output = ""
	if format == "csv" then
		output = ns.MoneyTable.To.CSV(realmFields, moneyTable)
	elseif format == "json" then
		output = ns.MoneyTable.To.JSON("realms", moneyTable)
	end

	self:SendMessage("GoldStockSummary_SetExportRealmsOutput", output)
end
