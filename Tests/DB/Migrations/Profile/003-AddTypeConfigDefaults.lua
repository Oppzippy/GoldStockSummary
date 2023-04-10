---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationProfile003MigrateFilters = {}

function TestMigrationProfile003MigrateFilters:TestEmptyDB()
	local db = {}
	ns.migrations.profile[3](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationProfile003MigrateFilters:TestNoFilters()
	local db = {
		filters = {},
	}
	ns.migrations.profile[3](db)
	luaunit.assertEquals(db, { filters = {} })
end

function TestMigrationProfile003MigrateFilters:TestNoTypeConfigs()
	local db = {
		filters = {
			{
				type = "characterWhitelist",
				typeConfig = {},
			},
		},
	}
	ns.migrations.profile[3](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterWhitelist",
				typeConfig = {
					characterWhitelist = {
						characters = {},
					},
				},
			},
		},
	})
end

function TestMigrationProfile003MigrateFilters:TestSomeMissingFields()
	local db = {
		filters = {
			{
				type = "characterCopper",
				typeConfig = {
					characterCopper = {
						sign = ">",
					},
				},
			},
		},
	}
	ns.migrations.profile[3](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterCopper",
				typeConfig = {
					characterCopper = {
						sign = ">",
						copper = 0,
					},
				},
			},
		},
	})
end

function TestMigrationProfile003MigrateFilters:TestMultipleTypeConfigs()
	local db = {
		filters = {
			{
				type = "characterCopper",
				typeConfig = {
					characterCopper = {
						sign = ">",
					},
					characterWhitelist = {},
				},
			},
		},
	}
	ns.migrations.profile[3](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterCopper",
				typeConfig = {
					characterCopper = {
						sign = ">",
						copper = 0,
					},
					characterWhitelist = {
						characters = {},
					},
				},
			},
		},
	})
end
