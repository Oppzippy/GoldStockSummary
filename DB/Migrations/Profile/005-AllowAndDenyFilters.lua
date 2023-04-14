---@class ns
local ns = select(2, ...)

ns.migrations.profile[5] = function(db)
	if not db or not db.filters then return end

	for _, config in next, db.filters do
		local filterReplacements = {
			{ allow = "characterWhitelist",        deny = "characterBlacklist",        new = "character", },
			{ allow = "characterPatternWhitelist", deny = "characterPatternBlacklist", new = "characterPattern", },
		}
		-- Default everything to allow and specifically mark deny filters
		config.action = "allow"
		for _, replacement in next, filterReplacements do
			local allowConfig = config.typeConfig[replacement.allow]
			local denyConfig = config.typeConfig[replacement.deny]
			if allowConfig or denyConfig then
				-- Prefer allow unless deny is the currently selected type
				if config.type == replacement.deny then
					config.action = "deny"
					config.typeConfig[replacement.new] = denyConfig or allowConfig
				else
					config.typeConfig[replacement.new] = allowConfig or denyConfig
				end
				config.typeConfig[replacement.allow] = nil
				config.typeConfig[replacement.deny] = nil
				if config.type == replacement.allow or config.type == replacement.deny then
					config.type = replacement.new
				end
			end
		end
	end
end
