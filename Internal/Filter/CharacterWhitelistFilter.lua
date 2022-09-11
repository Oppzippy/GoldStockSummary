---@class ns
local ns = select(2, ...)

local export = {}

---@class CharacterWhitelistFilter : Filter
---@field characters table<string, boolean>
local CharacterWhitelistFilterPrototype = {}

function export.Create(characters)
	return setmetatable({
		characters = characters,
	}, { __index = CharacterWhitelistFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function CharacterWhitelistFilterPrototype:Filter(pool)
	local newPool = {}
	local allowed = {}
	for character in next, pool do
		if self.characters[character] then
			allowed[character] = true
		else
			newPool[character] = true
		end
	end
	return newPool, allowed
end

ns.CharacterWhitelistFilter = export
