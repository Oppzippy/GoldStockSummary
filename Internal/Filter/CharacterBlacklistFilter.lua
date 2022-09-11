---@class ns
local ns = select(2, ...)

local export = {}

---@class CharacterBlacklistFilter : Filter
---@field characters table<string, boolean>
local CharacterBlacklistFilterPrototype = {}

function export.Create(characters)
	return setmetatable({
		characters = characters,
	}, { __index = CharacterBlacklistFilterPrototype })
end

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function CharacterBlacklistFilterPrototype:Filter(pool)
	local newPool = {}
	for character in next, pool do
		if not self.characters[character] then
			newPool[character] = true
		end
	end
	return newPool, {}
end

ns.CharacterBlacklistFilter = export
