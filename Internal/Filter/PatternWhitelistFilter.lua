---@class ns
local ns = select(2, ...)

local export = {}

---@class PatternWhitelistFilter : Filter
---@field pattern string
local PatternWhitelistFilterPrototype = {}

---@param name string
---@param pattern string
---@return PatternWhitelistFilter
function export.Create(name, pattern)
	return setmetatable({
		name = name,
		pattern = pattern,
	}, { __index = PatternWhitelistFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function PatternWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for character, value in next, pool do
		if character:find(self.pattern) then
			allowed[character] = value
		else
			newPool[character] = value
		end
	end
	return newPool, allowed
end

ns.PatternWhitelistFilter = export
