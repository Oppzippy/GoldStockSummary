---@class ns
local _, ns = ...
local export = {}

local scrollingTableColumns = {
	name = {
		name = "Name",
		width = 100,
	},
	realm = {
		name = "Realm",
		width = 100,
	},
	copper = {
		name = "Copper",
		width = 100,
	},
	personalCopper = {
		name = "Personal Copper",
		width = 100,
	},
	guildBankCopper = {
		name = "Guild Bank Copper",
		width = 100,
	},
	lastUpdate = {
		name = "Last Update",
		width = 150,
	},
}

---@param fields string[]
---@return table
function export.FieldsToScrollingTableColumns(fields)
	local columns = {}
	for i, field in ipairs(fields) do
		columns[i] = scrollingTableColumns[field]
	end
	return columns
end

if ns then
	ns.ScrollingTableConversion = export
end
return export
