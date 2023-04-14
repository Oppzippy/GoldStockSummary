---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCharacterWhitelist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCharacterWhitelist:TestCharacterWhitelistAll()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "character",
			name = "?",
			action = "allow",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
						["Name2-Realm"] = true,
						["Name3-Realm2"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))

	luaunit.assertEquals(allowed, pool)
end

function TestCharacterWhitelist:TestCharacterWhitelistSome()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "character",
			name = "?",
			action = "allow",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
						["Name4-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
	})
end

function TestCharacterWhitelist:TestCharacterWhitelistNone()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "character",
			name = "?",
			action = "allow",
			typeConfig = {
				character = {
					characters = {},
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {})
end
