---@class ns
local ns = select(2, ...)

local date = date or os.date

---@param tableType string
---@param moneyTable MoneyTable
---@return string
local function ToJSON(tableType, moneyTable)
	moneyTable = moneyTable:ConvertTypes({
		copper = {
			type = "string",
			converter = function(value) return value and tostring(value) end,
		},
		gold = {
			type = "string",
			converter = function(value) return value and tostring(value * COPPER_PER_GOLD) end,
		},
		timestamp = {
			type = "string",
			converter = function(value)
				return value and date("!%Y-%m-%dT%TZ", value)
			end,
		},
	})

	return C_EncodingUtil.SerializeJSON({
		type = tableType,
		data = moneyTable.entries,
	})
end

---@class ns.MoneyTable.To
local To = ns.MoneyTable.To
To.JSON = ToJSON
