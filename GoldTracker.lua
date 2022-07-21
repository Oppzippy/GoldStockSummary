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
end

function Core:ToggleUI()
	if ns.CharacterScrollingTable:IsVisible() then
		ns.CharacterScrollingTable:Hide()
	else
		self:ShowCharacterGoldTable()
	end
end

function Core:ShowCharacterGoldTable()
	local columns, data = self:CharacterGoldTable()

	ns.CharacterScrollingTable:Show(columns, data)
	ns.CharacterScrollingTable.RegisterCallback(self, "OnDelete", "OnDeleteCharacter")
	ns.CharacterScrollingTable.RegisterCallback(self, "OnExportJSON")
	ns.CharacterScrollingTable.RegisterCallback(self, "OnExportCSV")
end

local characterFields = { "realm", "faction", "name", "totalMoney", "personalMoney", "guildBankMoney", "lastUpdate" }

function Core:CharacterGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTable.From.TrackedMoney(db.characters, db.guilds)

	local scrollingTableColumns, scrollingTableData = ns.MoneyTable.To.ScrollingTable(characterFields,
		moneyTable)

	return scrollingTableColumns, scrollingTableData
end

function Core:OnDeleteCharacter(_, nameAndRealm)
	self.db.global.characters[nameAndRealm] = nil
	local _, newDataTable = self:CharacterGoldTable()
	ns.CharacterScrollingTable:SetData(newDataTable)
end

function Core:OnExportCSV()
	local db = self.db.global
	local moneyTable = ns.MoneyTable.From.TrackedMoney(db.characters, db.guilds)
	local csv = ns.MoneyTable.To.CSV(characterFields, moneyTable)

	ns.CharacterScrollingTable:SetExportText(csv)
end

function Core:OnExportJSON()
	local db = self.db.global
	local moneyTable = ns.MoneyTable.From.TrackedMoney(db.characters, db.guilds)
	local json = ns.MoneyTable.To.JSON(moneyTable)

	ns.CharacterScrollingTable:SetExportText(json)
end
