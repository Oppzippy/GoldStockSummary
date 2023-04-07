---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestPatternBlacklist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestPatternBlacklist:TestPatternBlacklistAll()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "characterPatternBlacklist",
			listFilterType = "pattern",
			name = "?",
			pattern = ".*",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {})
end

function TestPatternBlacklist:TestPatternBlacklistSome()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "characterPatternBlacklist",
			name = "?",
			pattern = ".+-Realm2",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
end

function TestPatternBlacklist:TestPatternBlacklistNone()
	local whitelist = ns.Filter.FromConfigurations({
		{
			type = "characterPatternBlacklist",
			name = "?",
			pattern = "does not match any characters",
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
end
