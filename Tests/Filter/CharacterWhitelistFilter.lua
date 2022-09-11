---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestCharacterWhitelist = {}

local pool = {
	["Name1-Realm"] = true,
	["Name2-Realm"] = true,
	["Name3-Realm2"] = true,
}

function TestCharacterWhitelist:TestCharacterWhitelistAll()
	local whitelist = ns.Filter.FromConfiguration({
		type = "whitelist",
		listFilterType = "characterList",
		name = "?",
		characters = {
			["Name1-Realm"] = true,
			["Name2-Realm"] = true,
			["Name3-Realm2"] = true,
		},
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {})
	luaunit.assertEquals(allowed, pool)
end

function TestCharacterWhitelist:TestCharacterWhitelistSome()
	local whitelist = ns.Filter.FromConfiguration({
		type = "whitelist",
		listFilterType = "characterList",
		name = "?",
		characters = {
			["Name1-Realm"] = true,
			["Name4-Realm"] = true,
		},
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, {
		["Name2-Realm"] = true,
		["Name3-Realm2"] = true,
	})
	luaunit.assertEquals(allowed, {
		["Name1-Realm"] = true,
	})
end

function TestCharacterWhitelist:TestCharacterWhitelistNone()
	local whitelist = ns.Filter.FromConfiguration({
		type = "whitelist",
		listFilterType = "characterList",
		name = "?",
		characters = {},
	})

	local newPool, allowed = whitelist:Filter(pool)
	luaunit.assertEquals(newPool, pool)
	luaunit.assertEquals(allowed, {})
end
