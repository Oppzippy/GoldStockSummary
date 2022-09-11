---@class ns
local ns = select(2, ...)

local export = {}

---@class CombinedFilter : Filter
---@field name string
---@field filters Filter[]
local CombinedFilterPrototype = {}

---@param name string
---@param filters Filter[] It is expected that filter loops have been checked for already.
---@return CombinedFilter
function export.Create(name, filters)
	return setmetatable({
		name = name,
		filters = filters,
	}, { __index = CombinedFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function CombinedFilterPrototype:Filter(pool)
	local allowed = {}

	for _, filter in ipairs(self.filters) do
		local addToAllowed
		pool, addToAllowed = filter:Filter(pool)
		for character in next, addToAllowed do
			allowed[character] = true
		end
	end

	return pool, allowed
end

ns.CombinedFilter = export
