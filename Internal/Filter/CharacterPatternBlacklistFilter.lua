---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterPatternBlacklistFilterFactory: FilterFactory
local CharacterPatternBlacklistFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "characterPatternBlacklist",
	localizedName = L.character_pattern_blacklist,
	terminus = "allow",
}

---@class CharacterPatternBlacklistFilterConfiguration
---@field pattern string

---@param filterName string
---@param config CharacterPatternBlacklistFilterConfiguration
---@return Filter
function CharacterPatternBlacklistFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool)
		local newPool = {}
		for name, trackedCharacter in next, pool do
			if not name:find(config.pattern) then
				newPool[name] = trackedCharacter
			end
		end
		return newPool, {}
	end)
end

---@return CharacterPatternBlacklistFilterConfiguration
function CharacterPatternBlacklistFilterFactory:DefaultConfiguration()
	return {
		pattern = "",
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterPatternBlacklistFilterFactory:OptionsTable(config, db)
	local typeConfig = config.typeConfig[self.type]
	return {
		type = "group",
		args = {
			pattern = {
				type = "input",
				name = L.pattern,
				width = "full",
				order = 7,
				get = function()
					return typeConfig.pattern
				end,
				set = function(_, pattern)
					typeConfig.pattern = pattern
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
		}
	}
end

ns.FilterRegistry:Register(CharacterPatternBlacklistFilterFactory)
