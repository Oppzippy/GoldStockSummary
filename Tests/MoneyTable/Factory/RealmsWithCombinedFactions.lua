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


	local moneyTable = ns.MoneyTable.Factory.RealmsWithCombinedFactions(ns.TrackedMoney.Create(characters, guilds))
	local result = moneyTable:ToRows({ "realm", "totalMoney", "personalMoney", "guildBankMoney" })

	luaunit.assertItemsEquals(result, {
		{
			"Illidan", -- name
			26, -- totalMoney
			25, -- personalMoney
			1, -- guildBankMoney
		},
		{
			"Sargeras", -- name
			6, -- totalMoney
			6, -- personalMoney
			0, -- guildBankMoney
		},
	})
end
