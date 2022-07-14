local luaunit = require("luaunit")
local MoneyTableConversion = require("Internal.MoneyTableConversion")

TestTrackedMoneyToCharacterMoneyTable = {}

function TestTrackedMoneyToCharacterMoneyTable:TestCharactersOnly()
	local characters = {
		["Test-Illidan"] = {
			copper = 5,
		},
		["Test2-Illidan"] = {
			copper = 10,
		},
	}

	local result = MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(characters)

	luaunit.assertEquals(#result, 2)
	local expected = {
		{
			name = "Test",
			realm = "Illidan",
			copper = 5,
			personalCopper = 5,
		},
		{
			name = "Test2",
			realm = "Illidan",
			copper = 10,
			personalCopper = 10,
		},
	}
	luaunit.assertItemsEquals(result, expected)
end

function TestTrackedMoneyToCharacterMoneyTable:TestGuilds()
	local characters = {
		["Test-Illidan"] = {
			copper = 5,
			guild = "Bank-Illidan",
		},
		["Test2-Illidan"] = {
			copper = 10,
			guild = "Bank-Illidan",
		},
		["Test3-Illidan"] = {
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

	local result = MoneyTableConversion.TrackedMoneyToCharacterMoneyTable(characters, guilds)

	local expected = {
		{
			name = "Test",
			realm = "Illidan",
			copper = 15,
			personalCopper = 5,
			guildBankCopper = 10,
		},
		{
			name = "Test2",
			realm = "Illidan",
			copper = 10,
			personalCopper = 10,
		},
		{
			name = "Test3",
			realm = "Illidan",
			copper = 1,
			guildBankCopper = 0,
			personalCopper = 1,
		}
	}
	luaunit.assertItemsEquals(result, expected)
end
