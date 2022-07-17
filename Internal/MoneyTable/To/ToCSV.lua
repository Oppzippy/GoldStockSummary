---@class ns
local _, ns = ...

---@param fields string[]
---@param moneyTable MoneyTable
---@return string
local function ToCSV(fields, moneyTable)
	moneyTable = moneyTable:ConvertTypes({
		copper = {
			type = "gold",
			converter = function(value) return value and value / COPPER_PER_GOLD end,
		},
		timestamp = {
			type = "string",
			converter = function(value)
				return value and os.date("!%Y-%m-%dT%TZ", value)
			end,
		},
	})

	local rows = moneyTable:ToRows(fields)

	local csvLines = {}
	for i, row in ipairs(rows) do
		csvLines[i] = table.concat(row, ",")
	end
	return table.concat(csvLines, "\n")
end

---@class ns.MoneyTable.To
local To = ns.MoneyTable.To
To.CSV = ToCSV
