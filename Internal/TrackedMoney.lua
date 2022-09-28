---@class ns
local ns = select(2, ...)

---@class TrackedMoney
---@field characters table<string, TrackedCharacter>
---@field guilds table<string, TrackedGuild>
local TrackedMoneyPrototype = {}

---@param characters table<string, TrackedCharacter>
---@param guilds table<string, TrackedGuild>
---@return TrackedMoney
local function CreateTrackedMoney(characters, guilds)
	local trackedMoney = setmetatable({
		characters = characters,
		guilds = guilds,
	}, {
		__index = TrackedMoneyPrototype,
	})
	return trackedMoney
end

---@param nameAndRealm string
function TrackedMoneyPrototype:GetCharacterCopper(nameAndRealm)
	local character = self.characters[nameAndRealm]
	local guildCopper
	if character.guild then
		local guild = self.guilds[character.guild]
		---@cast guild TrackedGuild
		if guild and not guild.isBlacklisted and guild.copper and guild.owner == nameAndRealm then
			guildCopper = guild.copper
		end
	end
	return {
		totalCopper = character.copper + (guildCopper or 0),
		personalCopper = character.copper,
		guildCopper = guildCopper,
	}
end

function TrackedMoneyPrototype:IterateCharacters()
	local nameAndRealm
	return function()
		nameAndRealm = next(self.characters, nameAndRealm)
		return nameAndRealm
	end
end

local export = { Create = CreateTrackedMoney }
ns.TrackedMoney = export
