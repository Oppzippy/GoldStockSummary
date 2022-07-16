---@class ns
local _, ns = ...
local export = {}

---@alias DataTable (string|number)[][]

---@param moneyTable table
---@param fields string[]
---@return DataTable, string[]
function export.CharacterMoneyTableToDataTable(moneyTable, fields)
	local dataTable = {}
	for i, entry in ipairs(moneyTable) do
		local row = {}
		for j, field in ipairs(fields) do
			row[j] = entry[field]
		end
		dataTable[i] = row
	end
	return dataTable, ns.Util.CloneTableShallow(fields)
end

if ns then
	ns.DataTableConversion = export
end
return export
