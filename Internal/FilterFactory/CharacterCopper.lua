---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterCopperFilterFactory: FilterFactory
local CharacterCopperFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "characterCopper",
	localizedName = L.character_money,
	terminus = "deny",
}

---@class CharacterCopperFilterConfiguration
---@field sign "<" | "<=" | "=" | ">=" | ">"
---@field copper number


local compareFunction = setmetatable({
	["<"] = function(a, b) return a < b end,
	["<="] = function(a, b) return a <= b end,
	["="] = function(a, b) return a == b end,
	[">="] = function(a, b) return a >= b end,
	[">"] = function(a, b) return a > b end,
}, {
	-- Default to =
	__index = function()
		return function(a, b) return a == b end
	end,
})

---@param filterName string
---@param config CharacterCopperFilterConfiguration
---@return Filter
function CharacterCopperFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool)
		local allowed = {}
		local newPool = {}
		for name, trackedCharacter in next, pool do
			if compareFunction[config.sign](trackedCharacter.copper, config.copper) then
				allowed[name] = trackedCharacter
			else
				newPool[name] = trackedCharacter
			end
		end
		return newPool, allowed
	end)
end

---@return CharacterCopperFilterConfiguration
function CharacterCopperFilterFactory:DefaultConfiguration()
	return {
		sign = ">",
		copper = 0,
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterCopperFilterFactory:OptionsTable(config, db)
	local typeConfig = config.typeConfig[self.type]
	return {
		type = "group",
		args = {
			copperHeader = {
				type = "header",
				name = L.comparison,
				order = 7.05,
			},
			sign = {
				type = "select",
				name = L.sign,
				width = "half",
				order = 7.1,
				values = {
					["<"] = "<",
					["<="] = "<=",
					["="] = "=",
					[">="] = ">=",
					[">"] = ">",
				},
				sorting = { "<", "<=", "=", ">=", ">" },
				get = function()
					return typeConfig.sign
				end,
				set = function(_, sign)
					typeConfig.sign = sign
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			gold = {
				type = "input",
				name = L.gold,
				order = 7.2,
				get = function()
					local gold = ns.MoneyUtil.GetGold(typeConfig.copper or 0)
					return tostring(gold)
				end,
				set = function(_, gold)
					gold = tonumber(gold) or 0
					typeConfig.copper = ns.MoneyUtil.SetGoldUnit(typeConfig.copper or 0, gold)
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			silver = {
				type = "input",
				name = L.silver,
				width = "half",
				order = 7.3,
				get = function()
					local silver = ns.MoneyUtil.GetSilver(typeConfig.copper or 0)
					return tostring(silver)
				end,
				set = function(_, silver)
					silver = tonumber(silver) or 0
					typeConfig.copper = ns.MoneyUtil.SetSilverUnit(typeConfig.copper or 0, silver)
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			copper = {
				type = "input",
				name = L.copper,
				width = "half",
				order = 7.4,
				get = function()
					local copper = ns.MoneyUtil.GetCopper(typeConfig.copper or 0)
					return tostring(copper)
				end,
				set = function(_, copper)
					copper = tonumber(copper) or 0
					typeConfig.copper = ns.MoneyUtil.SetCopperUnit(typeConfig.copper or 0, copper)
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			}
		}
	}
end

ns.FilterFactoryRegistry:Register(CharacterCopperFilterFactory)
