---@class ns
local ns = select(2, ...)

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

---@param pool table<string, unknown>
---@return table<string, unknown> pool, table<string, unknown> accepted
function CharacterBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for character, value in next, pool do
		if not self.characters[character] then
			newPool[character] = value
		end
	end
	return newPool, {}
end

ns.CharacterBlacklistFilter = export
