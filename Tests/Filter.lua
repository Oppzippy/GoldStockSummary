---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestFilter = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestFilter:TestSingleAllowExcept()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "character",
			name = "?",
			action = "allowExcept",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]
	local newPool, accepted = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(accepted, {
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
end

function TestFilter:TestSingleDenyExcept()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "character",
			name = "?",
			action = "denyExcept",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]
	local newPool, accepted = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	-- Since it is a single filter by itself, it is terminated with allowAll, causing the pool to move to accepted
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(accepted, {
		["Name1-Realm"] = true,
	})
end

function TestFilter:TestCombinedAllowExcept()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			action = "allow",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2, 3 },
				}
			}
		},
		{
			type = "character",
			action = "allowExcept",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
		-- To show that matches were removed from the pool
		{
			type = "character",
			action = "allow",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
					},
				},
			},
		},
	})[1]

	local newPool, accepted = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(accepted, {
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
end

function TestFilter:TestCombinedDenyExcept()
	local filter = ns.FilterFactoryRegistry:Create({
		{
			type = "combinedFilter",
			action = "allow",
			typeConfig = {
				combinedFilter = {
					childFilterIDs = { 2, 3, 4 },
				}
			}
		},
		{
			type = "character",
			action = "denyExcept",
			typeConfig = {
				character = {
					characters = {
						["Name1-Realm"] = true,
						["Name2-Realm"] = true,
					},
				},
			},
		},
		-- To show that the characters were only kept in the pool, not explicitly allowed
		{
			type = "character",
			action = "deny",
			typeConfig = {
				character = {
					characters = {
						["Name2-Realm"] = true,
					},
				},
			},
		},
		{
			type = "characterPattern",
			action = "allow",
			typeConfig = {
				characterPattern = {
					pattern = ".*",
				},
			},
		}
	})[1]

	local newPool, accepted = filter:Filter(pool, ns.TrackedMoney.Create({}, {}))
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(accepted, {
		["Name1-Realm"] = true,
	})
end
