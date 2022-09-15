---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCharacterBlacklist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCharacterBlacklist:TestCharacterBlacklistAll()
	local blacklist = ns.Filter.FromConfigurations({
		{
			type = "blacklist",
			listFilterType = "characterList",
			name = "?",
			characters = {
				["Name1-Realm"] = true,
				["Name2-Realm"] = true,
				["Name3-Realm2"] = true,
			},
		},
	})[1]

	local newPool, allowed = blacklist:Filter(pool)
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(allowed, {})
end

function TestCharacterBlacklist:TestCharacterBlacklistSome()
	local blacklist = ns.Filter.FromConfigurations({
		{
			type = "blacklist",
			listFilterType = "characterList",
			name = "?",
			characters = {
				["Name1-Realm"] = true,
				["Name4-Realm"] = true,
			},
		},
	})[1]

	local newPool, allowed = blacklist:Filter(pool)
	luaunit.assertEquals(newPool, {
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
	luaunit.assertEquals(allowed, {})
end

function TestCharacterBlacklist:TestCharacterBlacklistNone()
	local blacklist = ns.Filter.FromConfigurations({
		{
			type = "blacklist",
			listFilterType = "characterList",
			name = "?",
			characters = {},
		},
	})[1]

	local newPool, allowed = blacklist:Filter(pool)
	luaunit.assertEquals(newPool, pool)
	luaunit.assertEquals(allowed, {})
end
