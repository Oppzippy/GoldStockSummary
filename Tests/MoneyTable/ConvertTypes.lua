---@class ns
local _, ns = ...

local luaunit = require("luaunit")

TestMoneyTableConvertTypes = {}

function TestMoneyTableConvertTypes:TestConvertTypes()
	local entries = {
		{
			name = "test",
			money = 1,
		},
		{
			name = "test2",
			money = 2,
		}
	}

	local moneyTable = ns.MoneyTable.Create({
		name = "string",
		money = "copper",
	}, entries)

	local newMoneyTable = moneyTable:ConvertTypes({
		copper = {
			type = "string",
			converter = function(value)
				return tostring(value)
			end,
		},
	})

	local expectedSchema = {
		name = "string",
		money = "string",
	}
	local expectedEntries = {
		{
			name = "test",
			money = "1",
		},
		{
			name = "test2",
			money = "2",
		},
	}
	luaunit.assertEquals(newMoneyTable.entries, expectedEntries)
	luaunit.assertEquals(newMoneyTable:GetSchema(), expectedSchema)
end
