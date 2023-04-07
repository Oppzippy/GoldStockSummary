---@class ns
local ns = select(2, ...)

local conversions = {
	whitelist = {
		characterList = "characterWhitelist",
		pattern = "characterPatternWhitelist",
	},
	blacklist = {
		characterList = "characterBlacklist",
		pattern = "characterPatternBlacklist",
	},
}

ns.migrations.profile[1] = function(db)
	if not db or not db.filters then return end

	for _, filterConfiguration in next, db.filters do
		if conversions[filterConfiguration.type] then
			if conversions[filterConfiguration.type][filterConfiguration.listFilterType] then
				filterConfiguration.type = conversions[filterConfiguration.type][filterConfiguration.listFilterType]
				filterConfiguration.listFilterType = nil
			end
		end
	end
end
