---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationProfile004MigrateFilters = {}

function TestMigrationProfile004MigrateFilters:TestEmptyDB()
	local db = {}
	ns.migrations.profile[4](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationProfile004MigrateFilters:TestNoFilters()
	local db = {
		filters = {},
	}
	ns.migrations.profile[4](db)
	luaunit.assertEquals(db, { filters = {} })
end

function TestMigrationProfile004MigrateFilters:TestSelectedFilterType()
	local db = {
		filters = {
			{
				type = "characterCopper",
				typeConfig = {
					characterCopper = {
						sign = ">",
						copper = 5,
					},
				},
			},
		},
	}
	ns.migrations.profile[4](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "copper",
				typeConfig = {
					copper = {
						leftHandSide = "character",
						sign = ">",
						copper = 5,
					},
				},
			},
		},
	})
end

function TestMigrationProfile004MigrateFilters:TestNotSelectedFilterType()
	local db = {
		filters = {
			{
				type = "characterWhitelist",
				typeConfig = {
					characterCopper = {
						sign = ">",
						copper = 5,
					},
					characterWhitelist = {
						characters = {},
					},
				},
			},
		},
	}
	ns.migrations.profile[4](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterWhitelist",
				typeConfig = {
					copper = {
						leftHandSide = "character",
						sign = ">",
						copper = 5,
					},
					characterWhitelist = {
						characters = {},
					},
				},
			},
		},
	})
end
