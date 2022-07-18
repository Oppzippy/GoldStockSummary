---@class ns
local _, ns = ...

local date = date or os.date

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GoldTracker")

---@param fields string[]
---@return string[]
local function LocalizeFields(fields)
	local localized = {}
	for i, field in next, fields do
		localized[i] = L["columns/" .. field]
	end
	return localized
end

---@param fields string[]
---@param moneyTable MoneyTable
---@return string
local function ToCSV(fields, moneyTable)
	moneyTable = moneyTable:ConvertTypes({
		copper = {
			type = "gold",
			converter = function(value) return value and value / COPPER_PER_GOLD end,
		},
		timestamp = {
			type = "string",
			converter = function(value)
				return value and date("!%Y-%m-%dT%TZ", value)
			end,
		},
	})

	local rows = moneyTable:ToRows(fields)

	local numFields = #fields
	local csvParts = { table.concat(LocalizeFields(fields), ",") }
	for _, row in ipairs(rows) do
		csvParts[#csvParts + 1] = "\n"
		for j = 1, numFields do
			csvParts[#csvParts + 1] = row[j]
			if j ~= numFields then
				csvParts[#csvParts + 1] = ","
			end
		end
	end
	return table.concat(csvParts)
end

---@class ns.MoneyTable.To
local To = ns.MoneyTable.To
To.CSV = ToCSV
