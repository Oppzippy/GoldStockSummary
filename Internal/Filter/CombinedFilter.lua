---@class ns
local ns = select(2, ...)

local export = {}

---@class CombinedFilterConfiguration : FilterConfiguration
---@field type "combinedFilter"
---@field childFilterIDs unknown[]

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

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function CombinedFilterPrototype:Filter(pool)
	local allowed = {}

	for _, filter in ipairs(self.filters) do
		local addToAllowed
		pool, addToAllowed = filter:Filter(pool)
		for name, trackedCharacter in next, addToAllowed do
			allowed[name] = trackedCharacter
		end
	end

	return pool, allowed
end

ns.CombinedFilter = export
