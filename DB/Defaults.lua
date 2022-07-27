---@class ns
local ns = select(2, ...)

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
---@field isBlacklisted? boolean

local dbDefaults = {
	---@class GlobalDB
	global = {
		---@type table<string, TrackedCharacter>
		characters = {},
		---@type table<string, TrackedGuild>
		guilds = {},
	},
	profile = {
		minimapIcon = {
			hide = false,
		},
	},
}

ns.dbDefaults = dbDefaults

return dbDefaults
