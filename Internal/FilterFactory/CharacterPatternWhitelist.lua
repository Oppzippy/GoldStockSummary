---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterPatternWhitelistFilterFactory: FilterFactory
local CharacterPatternWhitelistFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "characterPatternWhitelist",
	localizedName = L.character_pattern_whitelist,
	terminus = "deny",
}

---@class CharacterPatternWhitelistFilterConfiguration
---@field pattern string

---@param filterName string
---@param config CharacterPatternWhitelistFilterConfiguration
---@return Filter
function CharacterPatternWhitelistFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool)
		local newPool = {}
		local allowed = {}
		for name in next, pool do
			if name:find(config.pattern) then
				allowed[name] = true
			else
				newPool[name] = true
			end
		end
		return newPool, allowed
	end)
end

---@return CharacterPatternWhitelistFilterConfiguration
function CharacterPatternWhitelistFilterFactory:DefaultConfiguration()
	return {
		pattern = "",
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterPatternWhitelistFilterFactory:OptionsTable(config, db)
	local typeConfig = config.typeConfig[self.type]
	return {
		type = "group",
		args = {
			pattern = {
				type = "input",
				name = L.pattern,
				width = "full",
				order = 1,
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

ns.FilterFactoryRegistry:Register(CharacterPatternWhitelistFilterFactory)
