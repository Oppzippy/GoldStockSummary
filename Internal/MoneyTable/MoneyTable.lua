---@class ns
local _, ns = ...

---@alias MoneyTableEntryType "string"|"timestamp"|"copper"|"gold"

---@class MoneyTable
---@field schema table<string, MoneyTableEntryType>
---@field entries table<string, unknown>[]
local MoneyTablePrototype = {}

---@param schema table<string, MoneyTableEntryType>
---@param entries table<string, unknown>[]
---@return MoneyTable
local function CreateMoneyTable(schema, entries)
	local moneyTable = setmetatable({
		schema = schema,
		entries = entries,
	}, { __index = MoneyTablePrototype })
	return moneyTable
end

---@param field string
---@return MoneyTableEntryType
function MoneyTablePrototype:GetFieldType(field)
	return self.schema[field]
end

---@return table<string, MoneyTableEntryType>
function MoneyTablePrototype:GetSchema()
	return ns.Util.CloneTableShallow(self.schema)
end

---@param fields string[] Field order
---@return unknown[][]
function MoneyTablePrototype:ToRows(fields)
	local rows = {}
	for i, moneyTable in ipairs(self.entries) do
		local row = {}
		for j, field in ipairs(fields) do
			if self.schema[field] then
				row[j] = moneyTable[field]
			end
		end
		rows[i] = row
	end
	return rows
end

function MoneyTablePrototype:Map(newSchema, func)
	local entries = {}
	for i, entry in ipairs(self.entries) do
		entries[i] = func(entry)
	end
	return CreateMoneyTable(newSchema, entries)
end

function MoneyTablePrototype:MapFields(newSchema, func)
	return self:Map(newSchema, function(entry)
		local newEntry = {}
		for field, value in next, entry do
			newEntry[field] = func(value, field)
		end
		return newEntry
	end)
end

function MoneyTablePrototype:ConvertTypes(conversions, convertors)
	local newSchema = {}
	for field, type in next, self.schema do
		newSchema[field] = conversions[type] or type
	end

	return self:MapFields(newSchema, function(value, field)
		local type = self:GetFieldType(field)
		if conversions[type] then
			return convertors[type](value, field)
		end
		return value
	end)
end

---@class ns.MoneyTable
local moneyTableNS = ns.MoneyTable
moneyTableNS.Create = CreateMoneyTable
