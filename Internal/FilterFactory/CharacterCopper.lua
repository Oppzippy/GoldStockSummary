---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterCopperFilterFactory: FilterFactory
local CharacterCopperFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "copper",
	localizedName = L.money,
	terminus = "deny",
}

---@class CharacterCopperFilterConfiguration
---@field leftHandSide "character"|"guild"|"total"
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
	return ns.Filter.Create(filterName, function(pool, trackedMoney)
		local allowed = {}
		local newPool = {}
		for name in next, pool do
			local characterMoney = trackedMoney:GetCharacterCopper(name)
			local leftHandSide
			if config.leftHandSide == "character" then
				leftHandSide = characterMoney.personalCopper
			elseif config.leftHandSide == "guild" then
				leftHandSide = characterMoney.guildCopper
			elseif config.leftHandSide == "total" then
				leftHandSide = characterMoney.totalCopper
			end
			if compareFunction[config.sign](leftHandSide or 0, config.copper) then
				allowed[name] = true
			else
				newPool[name] = true
			end
		end
		return newPool, allowed
	end)
end

---@return CharacterCopperFilterConfiguration
function CharacterCopperFilterFactory:DefaultConfiguration()
	return {
		leftHandSide = "total",
		sign = ">",
		copper = 0,
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterCopperFilterFactory:OptionsTable(config, db)
	local typeConfig = config.typeConfig[self.type]
	---@cast typeConfig CharacterCopperFilterConfiguration
	return {
		type = "group",
		args = {
			character = {
				type = "toggle",
				name = L.character,
				order = 1,
				width = 0.7,
				get = function()
					return typeConfig.leftHandSide == "character"
				end,
				set = function()
					typeConfig.leftHandSide = "character"
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			guild = {
				type = "toggle",
				name = L.guild,
				order = 2,
				width = 0.7,
				get = function()
					return typeConfig.leftHandSide == "guild"
				end,
				set = function()
					typeConfig.leftHandSide = "guild"
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			total = {
				type = "toggle",
				name = L.total,
				order = 3,
				width = 0.7,
				get = function()
					return typeConfig.leftHandSide == "total"
				end,
				set = function()
					typeConfig.leftHandSide = "total"
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			},
			sign = {
				type = "select",
				name = L.sign,
				width = "half",
				order = 4,
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
				order = 5,
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
				order = 6,
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
				order = 7,
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
