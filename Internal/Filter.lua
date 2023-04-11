---@class ns
local ns = select(2, ...)

---@alias FilterFunction fun(pool: table<string, boolean>, trackedMoney: TrackedMoney): pool: table<string, boolean>, accepted: table<string, boolean>

---@class Filter
---@field name string
---@field private filterFunc FilterFunction
local FilterPrototype = {}

local filterMetatable = { __index = FilterPrototype }

---@param pool table<string, boolean>
---@param trackedMoney TrackedMoney
---@return table<string, boolean> pool, table<string, boolean> accepted
function FilterPrototype:Filter(pool, trackedMoney)
	return self.filterFunc(pool, trackedMoney)
end

ns.Filter = {
	---@param name string
	---@param filterFunc FilterFunction
	---@return Filter
	Create = function(name, filterFunc)
		return setmetatable({
			name = name,
			filterFunc = filterFunc,
		}, filterMetatable)
	end,
}
