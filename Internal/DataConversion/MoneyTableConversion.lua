---@class ns
local _, ns = ...

local export = {}

---@param characters table<string, TrackedCharacter>
---@param guilds? table<string, TrackedGuild>
---@return MoneyTableCollection
function export.TrackedMoneyToCharacterMoneyTable(characters, guilds)
	local entries = {}
	for nameAndRealm, info in next, characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")

		local totalCopper = info.copper
		local guildBankCopper
		if info.guild and guilds and guilds[info.guild] and guilds[info.guild].owner == nameAndRealm then
			guildBankCopper = guilds[info.guild].copper
			totalCopper = totalCopper + guildBankCopper
		end

		local entry = {
			name = name,
			realm = realm,
			totalMoney = totalCopper,
			personalMoney = info.copper,
			guildBankMoney = guildBankCopper,
			lastUpdate = info.lastUpdate,
		}
		entries[#entries + 1] = entry
	end

	return ns.MoneyTableCollection.Create({
		name = "string",
		realm = "string",
		totalMoney = "copper",
		personalMoney = "copper",
		guildBankMoney = "copper",
		lastUpdate = "timestamp",
	}, entries)
end

if ns then
	ns.MoneyTableConversion = export
end
return export
