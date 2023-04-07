---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationProfile001MigrateFilters = {}

function TestMigrationProfile001MigrateFilters:TestEmptyDB()
	local db = {}
	ns.migrations.profile[1](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationProfile001MigrateFilters:TestNoFilters()
	local db = {
		filters = {},
	}
	ns.migrations.profile[1](db)
	luaunit.assertEquals(db, { filters = {} })
end

function TestMigrationProfile001MigrateFilters:TestMigrateOneOfEachType()
	local db = {
		filters = {
			{
				type = "whitelist",
				listFilterType = "characterList",
				characters = {},
			},
			{
				type = "whitelist",
				listFilterType = "pattern",
				pattern = "123",
			},
			{
				type = "blacklist",
				listFilterType = "characterList",
				characters = {},
			},
			{
				type = "blacklist",
				listFilterType = "pattern",
				pattern = "456",
			},
			{
				type = "someOtherFilter",
			},
		},
	}
	ns.migrations.profile[1](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterWhitelist",
				characters = {},
			},
			{
				type = "characterPatternWhitelist",
				pattern = "123",
			},
			{
				type = "characterBlacklist",
				characters = {},
			},
			{
				type = "characterPatternBlacklist",
				pattern = "456",
			},
			{
				type = "someOtherFilter",
			},
		},
	})
end
