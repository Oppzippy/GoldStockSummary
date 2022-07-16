---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local JSON = LibStub("json.lua")

---@class GoldTrackerCore : AceConsole-3.0, AceEvent-3.0, AceAddon
local Core = AceAddon:NewAddon("GoldTracker", "AceConsole-3.0", "AceEvent-3.0")

function Core:OnInitialize()
	self.db = AceDB:New("GoldTrackerDB", ns.dbDefaults, true)
	ns.db = self.db

	self:RegisterChatCommand("goldtracker", "SlashCommand")
end

function Core:SlashCommand(args)
	self:ShowCharacterGoldTable()
end

function Core:CharacterGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(db.characters, db.guilds)
	local dataTable, fields = ns.DataTableConversion.CharacterMoneyTableToDataTable(moneyTable)
	local scrollingTable = ns.ScrollingTableConversion.DataTableToScrollingTableData(fields, dataTable)
	local columns = ns.ScrollingTableConversion.FieldsToScrollingTableColumns(fields)

	return scrollingTable, columns
end

function Core:ShowCharacterGoldTable()
	local data, columns = self:CharacterGoldTable()

	ns.CharacterScrollingTable:Show(columns, data)
	ns.CharacterScrollingTable.RegisterCallback(self, "OnDelete", "OnDeleteCharacter")
	ns.CharacterScrollingTable.RegisterCallback(self, "OnExportJSON")
	ns.CharacterScrollingTable.RegisterCallback(self, "OnExportCSV")
end

function Core:OnDeleteCharacter(_, nameAndRealm)
	self.db.global.characters[nameAndRealm] = nil
	local newDataTable = self:CharacterGoldTable()
	ns.CharacterScrollingTable:SetData(newDataTable)
end

function Core:OnExportCSV()
	local db = self.db.global
	local moneyTable = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(db.characters, db.guilds)
	local dataTable, fields = ns.DataTableConversion.CharacterMoneyTableToDataTable(moneyTable)

	local transformers = {
		ns.DataTableTransformers.CopperToGold,
		ns.DataTableTransformers.TimestampToRFC3339,
	}
	for _, transformer in ipairs(transformers) do
		transformer(fields, dataTable)
	end

	ViragDevTool_AddData(fields)
	ViragDevTool_AddData(dataTable)
end

function Core:OnExportJSON()
	local db = self.db.global
	local moneyTable = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(db.characters, db.guilds)
	local json = JSON.encode(moneyTable)
	print(json)
end
