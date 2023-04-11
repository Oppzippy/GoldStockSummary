---@class ns
local ns = select(2, ...)

---@class TrackedMoney
---@field characters table<string, TrackedCharacter>
---@field guilds table<string, TrackedGuild>
local TrackedMoneyPrototype = {}

---@class CharacterMoney
---@field totalCopper integer
---@field personalCopper integer
---@field guildCopper integer

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
---@return CharacterMoney
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
	local nameAndRealm, trackedCharacter
	return function()
		nameAndRealm, trackedCharacter = next(self.characters, nameAndRealm)
		return nameAndRealm, trackedCharacter
	end
end

ns.TrackedMoney = {
	Create = CreateTrackedMoney,
}
