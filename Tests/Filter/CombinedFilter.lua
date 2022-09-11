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
	---@type FilterConfiguration[]
	local filters = {
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2, 3 },
		},
		{
			name = "?",
			type = "blacklist",
			listFilterType = "characterList",
			characters = {
				["Name1-Realm"] = true,
			},
		},
		{
			name = "?",
			type = "whitelist",
			listFilterType = "characterList",
			characters = {
				["Name1-Realm"] = true,
				["Name2-Realm"] = true,
			},
		},
	}

	local filter = ns.Filter.FromConfiguration(filters[1], filters)
	local newPool, allowed = filter:Filter(pool)
	luaunit.assertEquals(newPool, { ["Name3-Realm2"] = true })
	luaunit.assertEquals(allowed, { ["Name2-Realm"] = true })
end

function TestCombinedFilter:TestWhitelistThenBlacklist()
	---@type FilterConfiguration[]
	local filters = {
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = { 2, 3 },
		},
		{
			name = "?",
			type = "whitelist",
			listFilterType = "characterList",
			characters = {
				["Name1-Realm"] = true,
				["Name2-Realm"] = true,
			},
		},
		{
			name = "?",
			type = "blacklist",
			listFilterType = "characterList",
			characters = {
				["Name1-Realm"] = true,
			},
		},
	}

	local filter = ns.Filter.FromConfiguration(filters[1], filters)
	local newPool, allowed = filter:Filter(pool)
	luaunit.assertEquals(newPool, { ["Name3-Realm2"] = true })
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
		["Name2-Realm"] = true,
	})
end

function TestCombinedFilter:TestEmpty()
	---@type FilterConfiguration[]
	local filters = {
		{
			name = "?",
			type = "combinedFilter",
			childFilterIDs = {},
		},
	}
	local filter = ns.Filter.FromConfiguration(filters[1], filters)
	local newPool, allowed = filter:Filter(pool)
	luaunit.assertEquals(newPool, pool)
	luaunit.assertEquals(allowed, {})
end

function TestCombinedFilter:TestFilterLoop()
	---@type FilterConfiguration[]
	local filters = {
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
	}

	local success, error = pcall(function()
		ns.Filter.FromConfiguration(filters[1], filters)
	end)

	luaunit.assertEquals(success, false)
	luaunit.assertStrContains(error, "filter loop")
end
