---@class ns
local _, ns = ...

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("GoldTracker")

local export = {}

---@param fields string[]
function export.LocalizeFields(fields)
	local localized = {}
	for i, field in next, fields do
		localized[i] = L["columns/" .. field]
	end
	return localized
end

ns.ColumnLocalizer = export
