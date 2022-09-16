---@class ns
local ns = select(2, ...)

local export = {}

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

---@param pool table<string, unknown>
---@return table<string, unknown> pool, table<string, unknown> accepted
function CharacterWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for character, value in next, pool do
		if self.characters[character] then
			allowed[character] = value
		else
			newPool[character] = value
		end
	end
	return newPool, allowed
end

ns.CharacterWhitelistFilter = export
