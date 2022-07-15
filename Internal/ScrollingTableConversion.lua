---@class ns
local _, ns = ...
local export = {}

local scrollingTableColumns = {
	name = {
		name = "Name",
		width = 100,
	},
	realm = {
		name = "Realm",
		width = 100,
	},
	copper = {
		name = "Copper",
		width = 135,
	},
	personalCopper = {
		name = "Personal Copper",
		width = 135,
	},
	guildBankCopper = {
		name = "Guild Bank Copper",
		width = 135,
	},
	lastUpdate = {
		name = "Last Update",
		width = 150,
	},
}


---@param fields string[]
---@return table
function export.FieldsToScrollingTableColumns(fields)
	local columns = {}
	for i, field in ipairs(fields) do
		columns[i] = scrollingTableColumns[field]
	end
	return columns
end

local moneyColumns = {
	copper = true,
	personalCopper = true,
	guildBankCopper = true,
}

local dateColumns = {
	lastUpdate = true,
}

local function cellUpdateText(text)
	return function(rowFrame, cellFrame, data, cols, row, realRow, column, fShow, table, ...)
		if fShow then
			cellFrame.text:SetText(text)
		end
	end
end

---@param fields string[]
---@param dataTable DataTable
function export.DataTableToScrollingTableData(fields, dataTable)
	local scrollingTable = {}
	for i, row in ipairs(dataTable) do
		scrollingTable[i] = {
			cols = {},
		}
		for j, columnName in ipairs(fields) do
			local col = {
				value = row[j]
			}
			if moneyColumns[columnName] then
				col.DoCellUpdate = cellUpdateText(col.value and GetMoneyString(col.value, true) or "")
			elseif dateColumns[columnName] then
				col.DoCellUpdate = cellUpdateText(col.value and date("%Y-%m-%d %I:%M %p", col.value) or "")
			end

			scrollingTable[i].cols[j] = col
		end
	end
	return scrollingTable
end

if ns then
	ns.ScrollingTableConversion = export
end
return export
