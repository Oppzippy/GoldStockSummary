---@class ns
local ns = select(2, ...)

local export = {}

---@class PatternBlacklistFilter : Filter
---@field pattern string
local PatternBlacklistFilterPrototype = {}

---@param name string
---@param pattern string
---@return PatternBlacklistFilter
function export.Create(name, pattern)
	return setmetatable({
		name = name,
		pattern = pattern,
	}, { __index = PatternBlacklistFilterPrototype })
end

---@param pool table<string, unknown>
---@return table<string, unknown> pool, table<string, unknown> accepted
function PatternBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for character, value in next, pool do
		if not character:find(self.pattern) then
			newPool[character] = value
		end
	end
	return newPool, {}
end

ns.PatternBlacklistFilter = export
