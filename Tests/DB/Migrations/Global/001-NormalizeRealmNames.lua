---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationGlobal001NormalizeRealmNames = {}

function TestMigrationGlobal001NormalizeRealmNames:TestEmptyDB()
	local db = {}
	ns.migrations.global[1](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationGlobal001NormalizeRealmNames:TestEmptyCharacters()
	local db = {
		characters = {},
	}
	ns.migrations.global[1](db)
	luaunit.assertEquals(db, { characters = {} })
end

function TestMigrationGlobal001NormalizeRealmNames:TestMixedNormalizedAndUnnormalized()
	local db = {
		characters = {
			["Name-Realm"] = {
				copper = 5,
			},
			["Name2-Realm 2"] = {
				copper = 10,
			},
			["Name3-Some Other Realm-2"] = {
				copper = 10,
			},
		},
	}
	ns.migrations.global[1](db)
	luaunit.assertEquals(db, {
		characters = {
			["Name-Realm"] = {
				name = "Name",
				realm = "Realm",
				copper = 5,
			},
			["Name2-Realm2"] = {
				name = "Name2",
				realm = "Realm 2",
				copper = 10,
			},
			["Name3-SomeOtherRealm2"] = {
				name = "Name3",
				realm = "Some Other Realm-2",
				copper = 10,
			},
		}
	})
end
