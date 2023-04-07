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
			type = "characterPatternWhitelist",
			listFilterType = "pattern",
			name = "?",
			pattern = ".*",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, pool)
end

function TestPatternWhitelist:TestPatternWhitelistSome()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "characterPatternWhitelist",
			listFilterType = "pattern",
			name = "?",
			pattern = ".+-Realm2",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name3-Realm2"] = true,
	})
end

function TestPatternWhitelist:TestPatternWhitelistNone()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "characterPatternWhitelist",
			name = "?",
			pattern = "does not match any characters",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {})
end
