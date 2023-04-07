---@class ns
local ns = select(2, ...)

local export = {}

---@class CharacterPatternBlacklistFilterConfiguration : FilterConfiguration
---@field type "characterPatternBlacklist"
---@field pattern string

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

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function PatternBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for name, trackedCharacter in next, pool do
		if not name:find(self.pattern) then
			newPool[name] = trackedCharacter
		end
	end
	return newPool, {}
end

ns.CharacterPatternBlacklistFilter = export
