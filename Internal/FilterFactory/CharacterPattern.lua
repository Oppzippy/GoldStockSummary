---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterPatternFilterFactory: FilterFactory
local CharacterPatternFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "characterPattern",
	localizedName = L.character_pattern,
}

---@class CharacterPatternFilterConfiguration
---@field pattern string

---@param filterName string
---@param action FilterAction
---@param config CharacterPatternFilterConfiguration
---@return Filter
function CharacterPatternFilterFactory:Create(filterName, action, config)
	return ns.Filter.Create(filterName, action, function(pool)
		local newPool = {}
		local selected = {}
		for name in next, pool do
			if name:find(config.pattern) then
				selected[name] = true
			else
				newPool[name] = true
			end
		end
		return newPool, selected
	end)
end

---@return CharacterPatternFilterConfiguration
function CharacterPatternFilterFactory:DefaultConfiguration()
	return {
		pattern = "",
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterPatternFilterFactory:OptionsTable(config, db)
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

ns.FilterFactoryRegistry:Register(CharacterPatternFilterFactory)
