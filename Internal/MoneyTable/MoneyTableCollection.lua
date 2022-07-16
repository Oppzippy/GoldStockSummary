---@class ns
local _, ns = ...

---@class MoneyTableCollection
---@field moneyTables (MoneyTable)[]
local MoneyTableCollectionPrototype = {}

local function CreateMoneyTableCollection(moneyTables)
	local collection = setmetatable({
		moneyTables = moneyTables,
	}, { __index = MoneyTableCollectionPrototype })
	return collection
end

---@param fields string[] Field order
---@return MoneyTableEntry[][]
function MoneyTableCollectionPrototype:ToRows(fields)
	local rows = {}
	for i, moneyTable in ipairs(self.moneyTables) do
		local row = {}
		for j, field in ipairs(fields) do
			row[j] = moneyTable[field] or ns.MoneyTableEntry.Nil
		end
		rows[i] = row
	end
	return rows
end

local export = {
	Create = CreateMoneyTableCollection,
}
if ns then
	ns.MoneyTableCollection = export
end
return export
