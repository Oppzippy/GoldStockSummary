---@class ns
local _, ns = ...

---@class MoneyTableCollection
---@field schema table<string, MoneyTableEntryType>
---@field moneyTables table<string, unknown>[]
local MoneyTableCollectionPrototype = {}

---@param schema table<string, MoneyTableEntryType>
---@param entries table<string, unknown>[]
---@return MoneyTableCollection
local function CreateMoneyTableCollection(schema, entries)
	local moneyTables = {}
	for i, entry in ipairs(entries) do
		moneyTables[i] = entry
	end

	local collection = setmetatable({
		schema = schema,
		moneyTables = moneyTables,
	}, { __index = MoneyTableCollectionPrototype })
	return collection
end

function MoneyTableCollectionPrototype:GetFieldType(field)
	return self.schema[field]
end

---@param fields string[] Field order
---@return MoneyTableEntry[][]
function MoneyTableCollectionPrototype:ToRows(fields)
	local rows = {}
	for i, moneyTable in ipairs(self.moneyTables) do
		local row = {}
		for j, field in ipairs(fields) do
			local type = self.schema[field]
			if type and moneyTable[field] then
				row[j] = ns.MoneyTableEntry.Create(type, moneyTable[field])
			else
				row[j] = ns.MoneyTableEntry.Nil
			end
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
