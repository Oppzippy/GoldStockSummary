---@class ns
local _, ns = ...

---@class AceDBObject-3.0
---@field global GlobalDB

---@class TrackedCharacter
---@field copper number
---@field lastUpdate integer
---@field faction "alliance"|"horde"|"neutral"
---@field guild? string

---@class TrackedGuild
---@field owner string
---@field copper? number
---@field lastUpdate? integer

local dbDefaults = {
	---@class GlobalDB
	global = {
		---@type table<string, TrackedCharacter>
		characters = {},
		---@type table<string, TrackedGuild>
		guilds = {},
	}
}

ns.dbDefaults = dbDefaults

return dbDefaults
