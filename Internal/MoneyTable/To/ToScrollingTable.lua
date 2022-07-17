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
---@param moneyTable MoneyTable
---@return table
local function FieldsToScrollingTableColumns(fields, moneyTable)
	local columns = {}
	for i, field in ipairs(fields) do
		columns[i] = {
			name = L["columns/" .. field],
			width = columnWidthByType[moneyTable:GetFieldType(field)]
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
---@param moneyTable MoneyTable
local function MoneyTableToScrollingTableData(fields, moneyTable)
	local scrollingTable = {}

	local rows = moneyTable:ToRows(fields)
	for i, row in ipairs(rows) do
		scrollingTable[i] = {
			cols = {},
		}
		for j, field in ipairs(fields) do
			local entry = row[j]
			local entryType = moneyTable:GetFieldType(field)
			local col = {
				value = entry,
			}
			if entryType == "copper" or entryType == "gold" then
				col.DoCellUpdate = cellUpdateText(col.value and GetMoneyString(col.value, true) or "")
			elseif entryType == "timestamp" then
				col.DoCellUpdate = cellUpdateText(col.value and date("%Y-%m-%d %I:%M %p", col.value) or "")
			end

			scrollingTable[i].cols[j] = col
		end
	end
	return scrollingTable
end

---@param fields string[]
---@param moneyTable MoneyTable
local function ToScrollingTable(fields, moneyTable)
	return FieldsToScrollingTableColumns(fields, moneyTable), MoneyTableToScrollingTableData(fields, moneyTable)
end

---@class ns.MoneyTable.To
local To = ns.MoneyTable.To
To.ScrollingTable = ToScrollingTable
