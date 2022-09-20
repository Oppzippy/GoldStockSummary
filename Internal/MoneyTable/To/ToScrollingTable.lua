---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale(addonName)

local columnWidthByType = setmetatable({
	copper = 135,
	gold = 135,
	timestamp = 135,
}, {
	__index = function()
		return 100
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
	return function(_, cellFrame, _, _, _, _, _, fShow)
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
				col.DoCellUpdate = cellUpdateText(entry and GetMoneyString(entry, true) or "")
				if not entry then
					col.value = 0
				end
			elseif entryType == "timestamp" then
				col.DoCellUpdate = cellUpdateText(entry and date("%Y-%m-%d %I:%M %p", entry) or "")
				if not entry then
					col.value = 0
				end
			elseif entryType == "faction" then
				col.DoCellUpdate = cellUpdateText(entry and L[entry] or "")
				if not entry then
					col.value = ""
				end
			else
				if not entry then
					col.value = ""
				end
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
