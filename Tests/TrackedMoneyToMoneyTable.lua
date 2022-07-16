---@class ns
local _, ns = ...

local luaunit = require("luaunit")

TestTrackedMoneyToCharacterMoneyTable = {}

local function resultValues(results)
	local values = {}
	for i, result in next, results do
		values[i] = {}
		for j, entry in next, result do
			values[i][j] = entry:GetValue()
		end
	end
	return values
end

function TestTrackedMoneyToCharacterMoneyTable:TestCharactersOnly()
	local characters = {
		["Test-Illidan"] = {
			copper = 5,
		},
		["Test2-Illidan"] = {
			copper = 10,
		},
	}

	local collection = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTableCollection(characters)
	local result = resultValues(collection:ToRows({ "name", "realm", "totalMoney", "personalMoney", "guildBankMoney" }))

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

	local collection = ns.MoneyTableConversion.TrackedMoneyToCharacterMoneyTableCollection(characters, guilds)
	local result = resultValues(collection:ToRows({ "name", "realm", "totalMoney", "personalMoney", "guildBankMoney" }))

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
