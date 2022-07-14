---@class ns
local _, ns = ...
local export = {}

---@alias DataTable (string|number)[][]

local fields = { "name", "realm", "copper", "personalCopper", "guildBankCopper", "lastUpdate" }
---@param moneyTable CharacterMoneyTable
---@return DataTable, string[]
function export.CharacterMoneyTableToDataTable(moneyTable)
	local dataTable = {}
	for i, entry in ipairs(moneyTable) do
		local row = {}
		for j, field in ipairs(fields) do
			row[j] = entry[field]
		end
		dataTable[i] = row
	end
	return dataTable, fields
end

if ns then
	ns.DataTableConversion = export
end
return export
