---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCombinedFilter = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCombinedFilter:TestBlacklistThenWhitelist()
	local filter = ns.Filter.FromConfigurations({
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2, 3 },
		},
		{
			name = "?",
			type = "characterBlacklist",
			characters = {
				["Name1-Realm"] = true,
			},
		},
		{
			name = "?",
			type = "characterWhitelist",
			characters = {
				["Name1-Realm"] = true,
				["Name2-Realm"] = true,
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool)
	luaunit.assertEquals(allowed, { ["Name2-Realm"] = true })
end

function TestCombinedFilter:TestWhitelistThenBlacklist()
	local filter = ns.Filter.FromConfigurations({
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2, 3 },
		},
		{
			name = "?",
			type = "characterWhitelist",
			characters = {
				["Name1-Realm"] = true,
				["Name2-Realm"] = true,
			},
		},
		{
			name = "?",
			type = "characterBlacklist",
			characters = {
				["Name1-Realm"] = true,
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool)
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
end

function TestCombinedFilter:TestEmpty()
	local filter = ns.Filter.FromConfigurations({
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = {},
		},
	})[1]
	local _, allowed = filter:Filter(pool)
	luaunit.assertEquals(allowed, {})
end

function TestCombinedFilter:TestFilterLoop()
	local filters, errors = ns.Filter.FromConfigurations({
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2 },
		},
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 1 },
		},
	})

	luaunit.assertNil(next(filters))
	luaunit.assertStrContains(errors[1], "filter loop")
	luaunit.assertStrContains(errors[2], "filter loop")
end

function TestCombinedFilter:TestSiblingFiltersShouldntCauseLoop()
	local filters, errors = ns.Filter.FromConfigurations({
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2, 2 },
		},
		{
			name = "?",
			type = "characterWhitelist",
		},
	})

	luaunit.assertNotNil(next(filters))
	luaunit.assertNil(next(errors))
end
