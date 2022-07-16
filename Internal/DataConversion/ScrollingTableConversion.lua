---@class ns
local _, ns = ...
local export = {}

local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GoldTracker")


local scrollingTableColumns = {
	name = {
		name = L["columns/name"],
		width = 100,
	},
	realm = {
		name = L["columns/realm"],
		width = 100,
	},
	totalMoney = {
		name = L["columns/totalMoney"],
		width = 135,
	},
	personalMoney = {
		name = L["columns/personalMoney"],
		width = 135,
	},
	guildBankMoney = {
		name = L["columns/guildBankMoney"],
		width = 135,
	},
	lastUpdate = {
		name = L["columns/lastUpdate"],
		width = 150,
	},
}


---@param fields string[]
---@return table
local function FieldsToScrollingTableColumns(fields)
	local columns = {}
	for i, field in ipairs(fields) do
		columns[i] = scrollingTableColumns[field]
	end
	return columns
end

local function cellUpdateText(text)
	return function(rowFrame, cellFrame, data, cols, row, realRow, column, fShow, table, ...)
		if fShow then
			cellFrame.text:SetText(text)
		end
	end
end

---@param fields string[]
---@param moneyTables MoneyTableCollection
local function MoneyTableCollectionToScrollingTableData(fields, moneyTables)
	local scrollingTable = {}

	local moneyTableRows = moneyTables:ToRows(fields)
	for i, row in ipairs(moneyTableRows) do
		scrollingTable[i] = {
			cols = {},
		}
		for j, entry in ipairs(row) do
			local col = {
				value = entry:GetValue(),
			}
			if entry:GetType() == "copper" or entry:GetType() == "gold" then
				col.DoCellUpdate = cellUpdateText(col.value and GetMoneyString(col.value, true) or "")
			elseif entry:GetType() == "timestamp" then
				col.DoCellUpdate = cellUpdateText(col.value and date("%Y-%m-%d %I:%M %p", col.value) or "")
			end

			scrollingTable[i].cols[j] = col
		end
	end
	return scrollingTable
end

---@param fields string[]
---@param moneyTables MoneyTableCollection
function export.FromMoneyTables(fields, moneyTables)
	return FieldsToScrollingTableColumns(fields), MoneyTableCollectionToScrollingTableData(fields, moneyTables)
end

if ns then
	ns.ScrollingTableConversion = export
end
return export
