---@class ns
local ns = select(2, ...)

---@class AceDBObject-3.0
---@diagnostic disable-next-line: duplicate-doc-field
---@field global GlobalDB

---@class TrackedCharacter
---@field name string
---@field realm string
---@field copper number
---@field lastUpdate integer
---@field faction "alliance"|"horde"|"neutral"
---@field guild? string

---@class TrackedAccountBank
---@field copper number
---@field lastUpdate integer

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
		---@type TrackedAccountBank?
		accountBank = nil,
	},
	profile = {
		minimapIcon = {
			hide = false,
		},
		csvFloorGold = false,
		selectedFilter = nil,
		filters = {},
		includeAccountBankInTotal = true,
		debugMode = false,
	},
}

ns.dbDefaults = dbDefaults
ns.migrations = {
	---@type fun(db: AceDBObject-3.0)[]
	global = {},
	profile = {},
}

return dbDefaults
