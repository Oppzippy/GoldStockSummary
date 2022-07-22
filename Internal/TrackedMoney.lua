---@class ns
local _, ns = ...

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

---@param name string
---@param realm string
function TrackedMoneyPrototype:GetCharacterCopper(name, realm)
	local nameAndRealm = string.format("%s-%s", name, realm)
	local character = self.characters[nameAndRealm]
	local guildCopper
	if character.guild then
		local guild = self.guilds[character.guild]
		---@cast guild TrackedGuild
		if guild and guild.copper then
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
		if nameAndRealm ~= nil then
			local name, realm = string.match(nameAndRealm, "(.*)-(.*)")
			return name, realm, nameAndRealm
		end
	end
end

local export = { Create = CreateTrackedMoney }
ns.TrackedMoney = export
