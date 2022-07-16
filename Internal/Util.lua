---@class ns
local _, ns = ...

local export = {}

---@param t table
---@return table
function export.CloneTableShallow(t)
	local copy = {}
	for key, value in next, t do
		copy[key] = value
	end
	return copy
end

do
	local function doNothing() end

	local function printError()
		error("attempt to update a read-only table")
	end

	---@generic T: table
	---@param t T
	---@param ignoreWrites? boolean
	---@return T
	function export.ReadOnlyTable(t, ignoreWrites)
		local proxy = setmetatable({}, {
			__index = t,
			__newindex = ignoreWrites and doNothing or printError,
		})
		return proxy
	end
end

ns.Util = export
