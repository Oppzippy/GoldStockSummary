---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local date = date or os.date

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale(addonName)

---@param fields string[]
---@return string[]
local function LocalizeFields(fields)
	local localized = {}
	for i, field in next, fields do
		localized[i] = L["columns/" .. field]
	end
	return localized
end

---@class ToCSVOptions
---@field floorGold? boolean

---@param fields string[]
---@param moneyTable MoneyTable
---@param options ToCSVOptions
---@return string
local function ToCSV(fields, moneyTable, options)
	moneyTable = moneyTable:ConvertTypes({
		copper = {
			type = "gold",
			converter = function(value)
				if value then
					local gold = value / COPPER_PER_GOLD
					return options.floorGold and math.floor(gold) or gold
				end
				return nil
			end,
		},
		timestamp = {
			type = "string",
			converter = function(value)
				return value and date("!%Y-%m-%dT%TZ", value)
			end,
		},
		faction = {
			type = "string",
			converter = function(value)
				return L[value]
			end,
		},
	})

	local rows = moneyTable:ToRows(fields)

	local numFields = #fields
	local csvLines = { table.concat(LocalizeFields(fields), ",") }
	for _, row in ipairs(rows) do
		local line = {}
		for j = 1, numFields do
			line[j] = row[j] or ""
		end
		csvLines[#csvLines + 1] = table.concat(line, ",")
	end
	return table.concat(csvLines, "\n")
end

---@class ns.MoneyTable.To
local To = ns.MoneyTable.To
To.CSV = ToCSV
