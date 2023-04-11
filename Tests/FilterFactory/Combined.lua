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
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2, 3 },
				},
			},
		},
		{
			type = "characterBlacklist",
			name = "?",
			typeConfig = {
				characterBlacklist = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
		{
			type = "characterWhitelist",
			name = "?",
			typeConfig = {
				characterWhitelist = {
					characters = {
						["Name1-Realm"] = true,
						["Name2-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, { ["Name2-Realm"] = true })
end

function TestCombinedFilter:TestSingleChildFilter()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2 },
				},
			},
		},
		{
			type = "characterWhitelist",
			name = "?",
			typeConfig = {
				characterWhitelist = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
	})
end

function TestCombinedFilter:TestWhitelistThenBlacklist()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2, 3 },
				},
			},
		},
		{
			type = "characterWhitelist",
			name = "?",
			typeConfig = {
				characterWhitelist = {
					characters = {
						["Name1-Realm"] = true,
						["Name2-Realm"] = true,
					},
				},
			},
		},
		{
			type = "characterBlacklist",
			name = "?",
			typeConfig = {
				characterBlacklist = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
end

function TestCombinedFilter:TestEmpty()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = {},
				},
			},
		},
	})[1]
	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {})
end

function TestCombinedFilter:TestFilterLoop()
	local filters, errors = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2 },
				},
			},
		},
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 1 },
				},
			},
		},
	})

	luaunit.assertNil(next(filters))
	luaunit.assertNotNil(errors)
	---@cast errors string[]
	luaunit.assertStrContains(errors[1], "filter loop")
	luaunit.assertStrContains(errors[2], "filter loop")
end

function TestCombinedFilter:TestSiblingFiltersShouldntCauseLoop()
	local filters, errors = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2, 2 },
				},
			},
		},
		{
			name = "?",
			type = "characterWhitelist",
			typeConfig = {
				characterWhitelist = {
					characters = {},
				},
			},
		},
	})

	luaunit.assertNotNil(next(filters))
	luaunit.assertNil(next(errors))
end

function TestCombinedFilter:TestNestedCombinedFilters()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2 },
				},
			},
		},
		{
			type = "combinedFilter",
			name = "?",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 3 },
				},
			},
		},
		{
			type = "characterWhitelist",
			name = "?",
			typeConfig = {
				characterWhitelist = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local _, allowed = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
	})
end
