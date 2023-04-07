---@class ns
local ns = select(2, ...)

local export = {}

---@class CharacterWhitelistFilterConfiguration : FilterConfiguration
---@field type "characterWhitelist"
---@field characters table<string, boolean>

---@class CharacterWhitelistFilter : Filter
---@field characters table<string, boolean>
local CharacterWhitelistFilterPrototype = {}

---@param name string
---@param characters string[]
---@return CharacterWhitelistFilter
function export.Create(name, characters)
	return setmetatable({
		name = name,
		characters = characters,
	}, { __index = CharacterWhitelistFilterPrototype })
end

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function CharacterWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for name, trackedCharacter in next, pool do
		if self.characters[name] then
			allowed[name] = trackedCharacter
		else
			newPool[name] = trackedCharacter
		end
	end
	return newPool, allowed
end

ns.CharacterWhitelistFilter = export
