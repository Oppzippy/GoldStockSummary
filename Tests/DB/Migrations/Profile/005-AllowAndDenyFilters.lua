---@class ns
local ns = select(2, ...)

local luaunit = require("luaunit")

TestMigrationProfile005AllowAndDenyFilters = {}

function TestMigrationProfile005AllowAndDenyFilters:TestEmptyDB()
	local db = {}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, {})
end

function TestMigrationProfile005AllowAndDenyFilters:TestNoFilters()
	local db = {
		filters = {},
	}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, { filters = {} })
end

function TestMigrationProfile005AllowAndDenyFilters:TestSelectedDenyFilter()
	local db = {
		filters = {
			{
				type = "characterBlacklist",
				typeConfig = {
					characterWhitelist = {
						characters = { "Whitelist-Test" },
					},
					characterBlacklist = {
						characters = { "Blacklist-Test" },
					},
				},
			},
		},
	}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "character",
				action = "deny",
				typeConfig = {
					character = {
						characters = { "Blacklist-Test" },
					},
				},
			},
		},
	})
end

function TestMigrationProfile005AllowAndDenyFilters:TestSelectedAllowFilter()
	local db = {
		filters = {
			{
				type = "characterPatternWhitelist",
				typeConfig = {
					characterPatternWhitelist = {
						pattern = "whitelist",
					},
					characterPatternBlacklist = {
						pattern = "blacklist",
					},
				},
			},
		},
	}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "characterPattern",
				action = "allow",
				typeConfig = {
					characterPattern = {
						pattern = "whitelist",
					},
				},
			},
		},
	})
end

function TestMigrationProfile005AllowAndDenyFilters:TestNotSelectedFilters()
	local db = {
		filters = {
			{
				type = "characterWhitelist",
				typeConfig = {
					characterPatternWhitelist = {
						pattern = "whitelist",
					},
					characterPatternBlacklist = {
						pattern = "blacklist",
					},
					characterWhitelist = {
						characters = { "Whitelist-Test" },
					},
					copper = {
						leftHandSide = "character",
						sign = ">",
						copper = 5,
					},
				},
			},
		},
	}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "character",
				action = "allow",
				typeConfig = {
					characterPattern = {
						pattern = "whitelist",
					},
					character = {
						characters = { "Whitelist-Test" },
					},
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

function TestMigrationProfile005AllowAndDenyFilters:TestSelectedCopperFilter()
	local db = {
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
	}
	ns.migrations.profile[5](db)
	luaunit.assertEquals(db, {
		filters = {
			{
				type = "copper",
				action = "allow",
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
