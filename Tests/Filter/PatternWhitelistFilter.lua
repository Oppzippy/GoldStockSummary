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
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "whitelist",
			listFilterType = "pattern",
			name = "?",
			pattern = ".*",
		},
	})[1]

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(allowed, pool)
end

function TestPatternWhitelist:TestPatternWhitelistSome()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "whitelist",
			listFilterType = "pattern",
			name = "?",
			pattern = ".+-Realm2",
		},
	})[1]

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
	luaunit.assertEquals(allowed, {
		["Name3-Realm2"] = true,
	})
end

function TestPatternWhitelist:TestPatternWhitelistNone()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "whitelist",
			listFilterType = "pattern",
			name = "?",
			pattern = "does not match any characters",
		},
	})[1]

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, pool)
	luaunit.assertEquals(allowed, {})
end
