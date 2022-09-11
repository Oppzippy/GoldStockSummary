---@class ns
local ns = select(2, ...)

local export = {}

---@class PatternWhitelistFilter : Filter
---@field pattern string
local PatternWhitelistFilterPrototype = {}

function export.Create(pattern)
	return setmetatable({
		pattern = pattern,
	}, { __index = PatternWhitelistFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function PatternWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for character in next, pool do
		if character:find(self.pattern) then
			allowed[character] = true
		else
			newPool[character] = true
		end
	end
	return newPool, allowed
end

ns.PatternWhitelistFilter = export
