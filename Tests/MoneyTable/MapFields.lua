---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMoneyTableMapFields = {}

function TestMoneyTableMap:TestModifyField()
	local entries = {
		{
			name = "test",
			uselessField = "nothing",
		},
		{
			name = "2test",
			uselessField = "nothing",
		}
	}

	local moneyTable = ns.MoneyTable.Create({
		name         = "string",
		uselessField = "string",
	}, entries)

	local newMoneyTable = moneyTable:MapFields({
		name = "string",
	}, function(value, field)
		if field == "name" then
			return value:sub(1, 1)
		end
		return value
	end)

	local expected = {
		{
			name = "t",
		},
		{
			name = "2"
		},
	}
	luaunit.assertEquals(newMoneyTable.entries, expected)
end
