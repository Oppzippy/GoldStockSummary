---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestTrackedMoneyToRealmsMoneyTable = {}

function TestTrackedMoneyToRealmsMoneyTable()
	local characters = {
		["Test-Illidan"] = {
			name = "Test",
			realm = "Illidan",
			faction = "Alliance",
			copper = 5,
			guild = "Test-Illidan",
		},
		["Test2-Illidan"] = {
			name = "Test2",
			realm = "Illidan",
			faction = "Alliance",
			copper = 10,
		},
		["Test3-Illidan"] = {
			name = "Test3",
			realm = "Illidan",
			faction = "Horde",
			copper = 10,
		},
		["Test4-Sargeras"] = {
			name = "Test3",
			realm = "Sargeras",
			faction = "Alliance",
			copper = 6,
		},
	}

	---@type TrackedGuild[]
	local guilds = {
		["Test-Illidan"] = {
			copper = 1,
			owner = "Test-Illidan",
		},
	}


	local moneyTable = ns.MoneyTable.Factory.Realms(ns.TrackedMoney.Create(characters, guilds))
	local result = moneyTable:ToRows({ "realm", "faction", "totalMoney", "personalMoney", "guildBankMoney" })

	luaunit.assertItemsEquals(result, {
		{
			"Illidan", -- name
			"Alliance", -- faction
			16, -- totalMoney
			15, -- personalMoney
			1, -- guildBankMoney
		},
		{
			"Illidan", -- name
			"Horde", -- faction
			10, -- totalMoney
			10, -- personalMoney
			0, -- guildBankMoney
		},
		{
			"Sargeras", -- name
			"Alliance", -- faction
			6, -- totalMoney
			6, -- personalMoney
			0, -- guildBankMoney
		},
	})
end
