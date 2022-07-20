---@class ns
local _, ns = ...

---@param characters table<string, TrackedCharacter>
---@param guilds? table<string, TrackedGuild>
---@return MoneyTable
local function FromTrackedMoney(characters, guilds)
	local entries = {}
	for nameAndRealm, info in next, characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")

		local totalCopper = info.copper
		local guildBankCopper
		if info.guild and guilds and guilds[info.guild] and guilds[info.guild].owner == nameAndRealm then
			guildBankCopper = guilds[info.guild].copper or 0
			totalCopper = totalCopper + guildBankCopper
		end

		local entry = {
			name = name,
			realm = realm,
			faction = info.faction,
			totalMoney = totalCopper,
			personalMoney = info.copper,
			guildBankMoney = guildBankCopper,
			lastUpdate = info.lastUpdate,
		}
		entries[#entries + 1] = entry
	end

	return ns.MoneyTable.Create({
		name = "string",
		realm = "string",
		faction = "faction",
		totalMoney = "copper",
		personalMoney = "copper",
		guildBankMoney = "copper",
		lastUpdate = "timestamp",
	}, entries)
end

---@class ns.MoneyTable.From
local From = ns.MoneyTable.From
From.TrackedMoney = FromTrackedMoney
