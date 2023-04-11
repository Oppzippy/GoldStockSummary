---@class ns
local ns = select(2, ...)

-- The behavior of the migration should not change as the defaults change, so hardcode the defaults at the time
-- of the creation of this migration
local defaults = {
	characterBlacklist = {
		characters = {},
	},
	characterWhitelist = {
		characters = {},
	},
	characterPatternBlacklist = {
		pattern = "",
	},
	characterPatternWhitelist = {
		pattern = "",
	},
	combinedFilter = {
		childFilterIDs = {},
	},
	characterCopper = {
		sign = "=",
		copper = 0,
	},
}

ns.migrations.profile[3] = function(db)
	if not db or not db.filters then return end

	for _, config in next, db.filters do
		if not config.typeConfig[config.type] then
			config.typeConfig[config.type] = {}
		end
		for type, typeConfig in next, config.typeConfig do
			local defaultTypeConfig = defaults[type]
			for k, v in next, defaultTypeConfig do
				if not typeConfig[k] then
					typeConfig[k] = v
				end
			end
		end
	end
end
