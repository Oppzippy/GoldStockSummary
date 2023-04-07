---@class ns
local ns = select(2, ...)

---@class CharacterCopperFilterConfiguration : FilterConfiguration
---@field type "characterCopper"
---@field sign "<" | "<=" | "=" | ">=" | ">"
---@field copper number

local export = {}

---@class CharacterCopperFilter : Filter
---@field sign "<" | "<=" | "=" | ">=" | ">"
---@field copper number
local CharacterCopperFilterPrototype = {}

---@param name string
---@param sign "<" | "<=" | "=" | ">=" | ">"
---@param copper number
---@return CharacterCopperFilter
function export.Create(name, sign, copper)
	return setmetatable({
		name = name,
		sign = sign,
		copper = copper,
	}, { __index = CharacterCopperFilterPrototype })
end

local compareFunction = setmetatable({
	["<"] = function(a, b) return a < b end,
	["<="] = function(a, b) return a <= b end,
	["="] = function(a, b) return a == b end,
	[">="] = function(a, b) return a >= b end,
	[">"] = function(a, b) return a > b end,
}, {
	-- Default to =
	__index = function()
		return function(a, b) return a == b end
	end,
})

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function CharacterCopperFilterPrototype:Filter(pool)
	local allowed = {}
	local newPool = {}
	for name, trackedCharacter in next, pool do
		if compareFunction[self.sign](trackedCharacter.copper, self.copper) then
			allowed[name] = trackedCharacter
		else
			newPool[name] = trackedCharacter
		end
	end
	return newPool, allowed
end

ns.CharacterCopperFilter = export
