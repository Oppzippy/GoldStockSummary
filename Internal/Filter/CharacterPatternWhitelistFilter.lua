---@class ns
local ns = select(2, ...)

local export = {}

---@class CharacterPatternWhitelistFilterConfiguration : FilterConfiguration
---@field type "characterPatternWhitelist"
---@field pattern string

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

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function PatternWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for name, trackedCharacer in next, pool do
		if name:find(self.pattern) then
			allowed[name] = trackedCharacer
		else
			newPool[name] = trackedCharacer
		end
	end
	return newPool, allowed
end

ns.CharacterPatternWhitelistFilter = export
