---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCharacterBlacklist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCharacterBlacklist:TestCharacterBlacklistAll()
	local blacklist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterBlacklist",
			name = "?",
			typeConfig = {
				characterBlacklist = {
					characters = {
						["Name1-Realm"] = true,
						["Name2-Realm"] = true,
						["Name3-Realm2"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = blacklist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {})
end

function TestCharacterBlacklist:TestCharacterBlacklistSome()
	local blacklist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterBlacklist",
			name = "?",
			typeConfig = {
				characterBlacklist = {
					characters = {
						["Name1-Realm"] = true,
						["Name4-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = blacklist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
end

function TestCharacterBlacklist:TestCharacterBlacklistNone()
	local blacklist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterBlacklist",
			name = "?",
			typeConfig = {
				characterBlacklist = {
					characters = {},
				},
			},
		},
	})[1]

	local _, allowed = blacklist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, pool)
end
