---@class ns
local ns = select(2, ...)

local fields = {
	characterBlacklist = { "characters" },
	characterWhitelist = { "characters" },
	characterPatternBlacklist = { "pattern" },
	characterPatternWhitelist = { "pattern" },
	characterCopper = { "sign", "copper" },
	combinedFilter = { "childFilterIDs" },
}

ns.migrations.profile[2] = function(db)
	if not db or not db.filters then return end

	for _, filterConfiguration in next, db.filters do
		filterConfiguration.typeConfig = {
			[filterConfiguration.type] = {},
		}
		for _, field in ipairs(fields[filterConfiguration.type] or {}) do
			filterConfiguration.typeConfig[filterConfiguration.type][field] = filterConfiguration[field]
			filterConfiguration[field] = nil
		end
	end
end
