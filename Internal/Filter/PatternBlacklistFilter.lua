---@class ns
local ns = select(2, ...)

local export = {}

---@class PatternBlacklistFilter : Filter
---@field pattern string
local PatternBlacklistFilterPrototype = {}

function export.Create(pattern)
	return setmetatable({
		pattern = pattern,
	}, { __index = PatternBlacklistFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function PatternBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for character in next, pool do
		if not character:find(self.pattern) then
			newPool[character] = true
		end
	end
	return newPool, {}
end

ns.PatternBlacklistFilter = export
