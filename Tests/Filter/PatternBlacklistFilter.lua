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
	local whitelist = ns.Filter.FromConfiguration({
		type = "blacklist",
		listFilterType = "pattern",
		name = "?",
		pattern = ".*",
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(allowed, {})
end

function TestPatternBlacklist:TestPatternBlacklistSome()
	local whitelist = ns.Filter.FromConfiguration({
		type = "blacklist",
		listFilterType = "pattern",
		name = "?",
		pattern = ".+-Realm2",
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
	luaunit.assertEquals(allowed, {})
end

function TestPatternBlacklist:TestPatternBlacklistNone()
	local whitelist = ns.Filter.FromConfiguration({
		type = "blacklist",
		listFilterType = "pattern",
		name = "?",
		pattern = "does not match any characters",
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, pool)
	luaunit.assertEquals(allowed, {})
end
