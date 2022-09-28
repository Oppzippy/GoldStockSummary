---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestTrackedMoneyToCharacterMoneyTable = {}

function TestTrackedMoneyToCharacterMoneyTable:TestCharactersOnly()
	local characters = {
		["Test-Illidan"] = {
			name = "Test",
			realm = "Illidan",
			copper = 5,
		},
		["Test2-Illidan"] = {
			name = "Test2",
			realm = "Illidan",
			copper = 10,
		},
	}

	local moneyTable = ns.MoneyTable.Factory.Characters(ns.TrackedMoney.Create(characters, {}))
	local result = moneyTable:ToRows({ "name", "realm", "totalMoney", "personalMoney", "guildBankMoney" })

	luaunit.assertEquals(#result, 2)
	local expected = {
		{
			"Test",
			"Illidan",
			5,
			5,
		},
		{
			"Test2",
			"Illidan",
			10,
			10,
		},
	}
	luaunit.assertItemsEquals(result, expected)
end

function TestTrackedMoneyToCharacterMoneyTable:TestGuilds()
	local characters = {
		["Test-Illidan"] = {
			name = "Test",
			realm = "Illidan",
			copper = 5,
			guild = "Bank-Illidan",
		},
		["Test2-Illidan"] = {
			name = "Test2",
			realm = "Illidan",
			copper = 10,
			guild = "Bank-Illidan",
		},
		["Test3-Illidan"] = {
			name = "Test3",
			realm = "Illidan",
			copper = 1,
			guild = "Bank2-Illidan",
		},
	}
	local guilds = {
		["Bank-Illidan"] = {
			copper = 10,
			owner = "Test-Illidan",
		},
		["Bank2-Illidan"] = {
			copper = 0,
			owner = "Test3-Illidan",
		},
	}

	local moneyTable = ns.MoneyTable.Factory.Characters(ns.TrackedMoney.Create(characters, guilds))
	local result = moneyTable:ToRows({ "name", "realm", "totalMoney", "personalMoney", "guildBankMoney" })

	local expected = {
		{
			"Test",
			"Illidan",
			15,
			5,
			10,
		},
		{
			"Test2",
			"Illidan",
			10,
			10,
		},
		{
			"Test3",
			"Illidan",
			1,
			1,
			0,
		}
	}
	luaunit.assertItemsEquals(result, expected)
end
