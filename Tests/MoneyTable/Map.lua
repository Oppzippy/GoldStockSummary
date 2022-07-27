---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMoneyTableMap = {}

function TestMoneyTableMap:TestReplaceFields()
	local entries = {
		{
			name = "test",
		},
		{
			name = "2test",
		}
	}

	local moneyTable = ns.MoneyTable.Create({
		name = "string",
	}, entries)

	local newMoneyTable = moneyTable:Map({
		firstLetter = "string",
	}, function(entry)
		return {
			firstLetter = entry.name:sub(1, 1)
		}
	end)

	local expected = {
		{
			firstLetter = "t",
		},
		{
			firstLetter = "2"
		},
	}
	luaunit.assertEquals(newMoneyTable.entries, expected)
end
