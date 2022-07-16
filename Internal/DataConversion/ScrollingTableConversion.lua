---@class ns
local _, ns = ...
local export = {}

local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale("GoldTracker")

local columnWidthByType = setmetatable({
	string = 100,
	copper = 135,
	gold = 135,
	timestamp = 150,
}, {
	__index = function(t, key)
		return t[key] or 100
	end,
})

---@param fields string[]
---@param collection MoneyTableCollection
---@return table
local function FieldsToScrollingTableColumns(fields, collection)
	local columns = {}
	for i, field in ipairs(fields) do
		columns[i] = {
			name = L["columns/" .. field],
			width = columnWidthByType[collection:GetFieldType(field)]
		}
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
---@param collection MoneyTableCollection
function export.FromMoneyTables(fields, collection)
	return FieldsToScrollingTableColumns(fields, collection), MoneyTableCollectionToScrollingTableData(fields, collection)
end

if ns then
	ns.ScrollingTableConversion = export
end
return export
