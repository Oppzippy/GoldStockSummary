---@class ns
local ns = select(2, ...)

---@alias FilterFunction fun(pool: table<string, TrackedCharacter>): pool: table<string, TrackedCharacter>, accepted: table<string, TrackedCharacter>

---@class Filter
---@field name string
---@field private filterFunc FilterFunction
local FilterPrototype = {}

local filterMetatable = { __index = FilterPrototype }

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function FilterPrototype:Filter(pool)
	return self.filterFunc(pool)
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
