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
	self:ShowCharacterGoldTable()
end

function Core:CharacterGoldTable()
	local db = self.db.global
	local moneyTable = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(db.characters, db.guilds)
	local dataTable, fields = ns.DataTableConversion.CharacterMoneyTableToDataTable(moneyTable)
	local columns = ns.ScrollingTableConversion.FieldsToScrollingTableColumns(fields)

	return dataTable, columns
end

function Core:ShowCharacterGoldTable()
	local dataTable, columns = self:CharacterGoldTable()
	ns.CharacterScrollingTable:Show(columns, dataTable)
	ns.CharacterScrollingTable:RegisterCallback("OnDelete", function(_, nameAndRealm)
		self.db.global.characters[nameAndRealm] = nil
		local newDataTable = self:CharacterGoldTable()
		ns.CharacterScrollingTable:SetData(newDataTable)
	end)
end
