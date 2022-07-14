---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local ScrollingTable = LibStub("ScrollingTable")

---@class GoldTrackerCore : AceConsole-3.0, AceEvent-3.0, AceAddon
local Core = AceAddon:NewAddon("GoldTracker", "AceConsole-3.0", "AceEvent-3.0")

function Core:OnInitialize()
	self.db = AceDB:New("GoldTrackerDB", ns.dbDefaults, true)
	ns.db = self.db

	self:RegisterChatCommand("goldtracker", "SlashCommand")
end

function Core:SlashCommand(args)
	self:CharacterGoldTable()
end

function Core:CharacterGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(db.characters, db.guilds)
	local dataTable, fields = ns.DataTableConversion.CharacterMoneyTableToDataTable(moneyTable)
	local columns = ns.ScrollingTableConversion.FieldsToScrollingTableColumns(fields)

	ns.CharacterScrollingTable:Show(columns, dataTable)
end
