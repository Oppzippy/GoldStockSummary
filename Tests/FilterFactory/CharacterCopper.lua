---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCharacterCopper = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCharacterCopper:TestAllSigns()
	local copper = 50
	local signs = {
		["<"] = { ["Name1-Realm"] = true },
		["<="] = { ["Name1-Realm"] = true,["Name2-Realm"] = true },
		["="] = { ["Name2-Realm"] = true },
		[">="] = { ["Name2-Realm"] = true,["Name3-Realm2"] = true },
		[">"] = { ["Name3-Realm2"] = true },
	}
	for sign, expectedAllowed in next, signs do
		local filter = ns.FilterFactoryRegistry:Create({
			{
				type = "copper",
				name = "?",
				typeConfig = {
					copper = {
						leftHandSide = "character",
						sign = sign,
						copper = copper,
					},
				},
			},
		})[1]

		local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({
			["Name1-Realm"] = {
				copper = copper - 1,
			},
			["Name2-Realm"] = {
				copper = copper,
			},
			["Name3-Realm2"] = {
				copper = copper + 1,
			},
		}, {}))
		luaunit.assertEquals(allowed, expectedAllowed, string.format("%s sign", sign))
	end
end

function TestCharacterCopper:TestIgnoresGuildMoney()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "copper",
			name = "?",
			typeConfig = {
				copper = {
					leftHandSide = "character",
					sign = "=",
					copper = 100,
				},
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({
		["Name1-Realm"] = {
			copper = 100,
			guild = "Guild1-Realm",
		},
		["Name2-Realm"] = {
			copper = 99,
			guild = "Guild2-Realm",
		},
		["Name3-Realm2"] = {
			copper = 3,
		},
	}, {
		["Guild1-Realm"] = {
			owner = "Name1-Realm",
			copper = 1,
		},
		["Guild2-Realm"] = {
			owner = "Name2-Realm",
			copper = 1,
		},
	}))
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
	})
end
