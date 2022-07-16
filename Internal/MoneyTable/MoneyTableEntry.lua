---@class ns
local _, ns = ...

---@alias MoneyTableEntryType "string"|"number"|"bignumber"|"timestamp"|"copper"|"gold"

---@param type MoneyTableEntryType
---@param value string|number|nil
---@return MoneyTableEntry
local function CreateMoneyTableEntry(type, value)
	---@class MoneyTableEntry
	local entry = {}

	---@return MoneyTableEntryType
	function entry:GetType()
		return type
	end

	function entry:GetValue()
		return value
	end

	function entry:HasValue()
		return value ~= nil
	end

	return entry
end

local export = {
	Create = CreateMoneyTableEntry,
	Nil = CreateMoneyTableEntry("nil", nil)
}
ns.MoneyTableEntry = export
