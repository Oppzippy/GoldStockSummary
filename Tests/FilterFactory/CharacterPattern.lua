---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestPatternWhitelist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestPatternWhitelist:TestPatternWhitelistAll()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPattern",
			name = "?",
			action = "allow",
			typeConfig = {
				characterPattern = {
					pattern = ".*",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, pool)
end

function TestPatternWhitelist:TestPatternWhitelistSome()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPattern",
			name = "?",
			action = "allow",
			typeConfig = {
				characterPattern = {
					pattern = ".+-Realm2",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name3-Realm2"] = true,
	})
end

function TestPatternWhitelist:TestPatternWhitelistNone()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPattern",
			name = "?",
			action = "allow",
			typeConfig = {
				characterPattern = {
					pattern = "does not match any characters",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {})
end
