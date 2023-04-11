---@class ns
local ns = select(2, ...)

ns.migrations.profile[4] = function(db)
	if not db or not db.filters then return end

	for _, config in next, db.filters do
		local characterCopperConfig = config.typeConfig["characterCopper"]
		if characterCopperConfig then
			config.typeConfig["copper"] = {
				leftHandSide = "character",
				sign = characterCopperConfig.sign,
				copper = characterCopperConfig.copper,
			}
			if config.type == "characterCopper" then
				config.type = "copper"
			end
			config.typeConfig["characterCopper"] = nil
		end
	end
end
