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
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPatternBlacklist",
			name = "?",
			typeConfig = {
				characterPatternBlacklist = {
					pattern = ".*",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {})
end

function TestPatternBlacklist:TestPatternBlacklistSome()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPatternBlacklist",
			name = "?",
			typeConfig = {
				characterPatternBlacklist = {
					pattern = ".+-Realm2",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
end

function TestPatternBlacklist:TestPatternBlacklistNone()
	local whitelist = ns.FilterFactoryRegistry:Create({
		{
			type = "characterPatternBlacklist",
			name = "?",
			typeConfig = {
				characterPatternBlacklist = {
					pattern = "does not match any characters",
				},
			},
		},
	})[1]

	local _, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
end
