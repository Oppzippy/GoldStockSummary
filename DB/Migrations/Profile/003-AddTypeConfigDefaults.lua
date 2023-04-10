---@class ns
local ns = select(2, ...)

ns.migrations.profile[3] = function(db)
	if not db or not db.filters then return end

	for _, config in next, db.filters do
		if not config.typeConfig[config.type] then
			config.typeConfig[config.type] = {}
		end
		for type, typeConfig in next, config.typeConfig do
			local defaultTypeConfig = ns.FilterFactoryRegistry:DefaultConfiguration(type)
			for k, v in next, defaultTypeConfig do
				if not typeConfig[k] then
					typeConfig[k] = v
				end
			end
		end
	end
end
