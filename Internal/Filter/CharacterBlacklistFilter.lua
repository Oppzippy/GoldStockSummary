---@class ns
local ns = select(2, ...)

---@class CharacterBlacklistFilterConfiguration : FilterConfiguration
---@field type "characterBlacklist"
---@field characters table<string, boolean>

local export = {}

---@class CharacterBlacklistFilter : Filter
---@field characters table<string, boolean>
local CharacterBlacklistFilterPrototype = {}

---@param name string
---@param characters string[]
---@return CharacterBlacklistFilter
function export.Create(name, characters)
	return setmetatable({
		name = name,
		characters = characters,
	}, { __index = CharacterBlacklistFilterPrototype })
end

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function CharacterBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for name, trackedCharacter in next, pool do
		if not self.characters[name] then
			newPool[name] = trackedCharacter
		end
	end
	return newPool, {}
end

ns.CharacterBlacklistFilter = export
