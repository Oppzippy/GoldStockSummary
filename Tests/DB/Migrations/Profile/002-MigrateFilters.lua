---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationProfile002MigrateFilters = {}

function TestMigrationProfile002MigrateFilters:TestEmptyDB()
	local db = {}
	ns.migrations.profile[2](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationProfile002MigrateFilters:TestNoFilters()
	local db = {
		filters = {},
	}
	ns.migrations.profile[2](db)
	luaunit.assertEquals(db, { filters = {} })
end

function TestMigrationProfile002MigrateFilters:TestMigrateOneOfEachType()
	local db = {
		filters = {
			{
				type = "characterWhitelist",
				name = "test1",
				characters = { "Test-Illidan" },
			},
			{
				type = "characterPatternWhitelist",
				name = "test2",
				pattern = "123",
			},
			{
				type = "characterBlacklist",
				name = "test3",
				characters = { "Test2-Illidan" },
			},
			{
				type = "characterPatternBlacklist",
				name = "test4",
				pattern = "456",
			},
			{
				type = "characterCopper",
				name = "test5",
				sign = "<",
				copper = 10,
			},
			{
				name = "test6",
				type = "combinedFilter",
				childFilterIDs = { 1, 2, 3 }
			},
			{
				name = "test7",
				type = "someOtherFilter",
			},
		},
	}
	ns.migrations.profile[2](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterWhitelist",
				name = "test1",
				typeConfig = {
					characterWhitelist = {
						characters = { "Test-Illidan" },
					},
				},
			},
			{
				type = "characterPatternWhitelist",
				name = "test2",
				typeConfig = {
					characterPatternWhitelist = {
						pattern = "123",
					},
				},
			},
			{
				type = "characterBlacklist",
				name = "test3",
				typeConfig = {
					characterBlacklist = {
						characters = { "Test2-Illidan" },
					},
				},
			},
			{
				type = "characterPatternBlacklist",
				name = "test4",
				typeConfig = {
					characterPatternBlacklist = {
						pattern = "456",
					},
				},
			},
			{
				type = "characterCopper",
				name = "test5",
				typeConfig = {
					characterCopper = {
						sign = "<",
						copper = 10,
					},
				},
			},
			{
				name = "test6",
				type = "combinedFilter",
				typeConfig = {
					combinedFilter = {
						childFilterIDs = { 1, 2, 3 }
					},
				},
			},
			{
				type = "someOtherFilter",
				name = "test7",
				typeConfig = {
					someOtherFilter = {},
				}
			},
		},
	})
end
