---@class ns
local ns = select(2, ...)

---@alias FilterFunction fun(pool: table<string, boolean>, trackedMoney: TrackedMoney): pool: table<string, boolean>, selected: table<string, boolean>
---@alias FilterAction "allow"|"allowExcept"|"deny"|"denyExcept"

---@class Filter
---@field name string
---@field action FilterAction
---@field private filterFunc FilterFunction
local FilterPrototype = {}

local filterMetatable = { __index = FilterPrototype }

---@param pool table<string, boolean>
---@param trackedMoney TrackedMoney
---@return table<string, boolean> pool, table<string, boolean> accepted
function FilterPrototype:Filter(pool, trackedMoney)
	local newPool, accepted = self.filterFunc(pool, trackedMoney)
	if self.action == "deny" then
		-- pass through what didn't match the filter, discard matches
		return newPool, {}
	elseif self.action == "denyExcept" then
		-- Pass through what was allowed as the new pool, discard everything else
		return accepted, {}
	elseif self.action == "allowExcept" then
		-- newPool contains everything that did not match the filter
		return {}, newPool
	end
	return newPool, accepted
end

ns.Filter = {
	---@param name string
	---@param action FilterAction
	---@param filterFunc FilterFunction
	---@return Filter
	Create = function(name, action, filterFunc)
		return setmetatable({
			name = name,
			action = action,
			filterFunc = filterFunc,
		}, filterMetatable)
	end,
}
