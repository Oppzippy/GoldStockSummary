---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")

---@class GoldTrackerCore : AceConsole-3.0, AceEvent-3.0, AceAddon
local Core = AceAddon:NewAddon("GoldTracker", "AceConsole-3.0", "AceEvent-3.0")

function Core:OnInitialize()
	self.db = AceDB:New("GoldTrackerDB", ns.dbDefaults, true)
	ns.db = self.db

	self:RegisterMessage("GoldTracker_ToggleUI", "ToggleUI")
	self:RegisterMessage("GoldTracker_DeleteCharacter", "OnDeleteCharacter")
	self:RegisterMessage("GoldTracker_ExportCharacters", "OnExportCharacters")
	self:RegisterMessage("GoldTracker_ExportRealms", "OnExportRealms")
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
	self:SendMessage("GoldTracker_MoneyUpdated")
end

---@param format string
function Core:OnExportCharacters(_, format)
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Characters(ns.TrackedMoney.Create(db.characters, db.guilds))

	local output = ""
	if format == "csv" then
		output = ns.MoneyTable.To.CSV(characterFields, moneyTable)
	elseif format == "json" then
		output = ns.MoneyTable.To.JSON(moneyTable)
	end

	self:SendMessage("GoldTracker_SetExportCharactersOutput", output)
end

function Core:OnExportRealms(_, format)
	local db = self.db.global
	local moneyTable = ns.MoneyTable.Factory.Realms(ns.TrackedMoney.Create(db.characters, db.guilds))

	local output = ""
	if format == "csv" then
		output = ns.MoneyTable.To.CSV(realmFields, moneyTable)
	elseif format == "json" then
		output = ns.MoneyTable.To.JSON(moneyTable)
	end

	self:SendMessage("GoldTracker_SetExportRealmsOutput", output)
end
