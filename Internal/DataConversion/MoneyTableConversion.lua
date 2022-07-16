---@class ns
local _, ns = ...

local export = {}

---@param characters table<string, TrackedCharacter>
---@param guilds? table<string, TrackedGuild>
---@return MoneyTableCollection
function export.TrackedMoneyToCharacterMoneyTable(characters, guilds)
	---@type MoneyTable[]
	local entries = {}
	for nameAndRealm, info in next, characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")

		local totalCopper = info.copper
		local guildBankCopper
		if info.guild and guilds and guilds[info.guild] and guilds[info.guild].owner == nameAndRealm then
			guildBankCopper = guilds[info.guild].copper
			totalCopper = totalCopper + guildBankCopper
		end

		---@type MoneyTable
		local entry = {
			name = ns.MoneyTableEntry.Create("string", name),
			realm = ns.MoneyTableEntry.Create("string", realm),
			totalMoney = ns.MoneyTableEntry.Create("copper", totalCopper),
			personalMoney = ns.MoneyTableEntry.Create("copper", info.copper),
			guildBankMoney = ns.MoneyTableEntry.Create("copper", guildBankCopper),
			lastUpdate = ns.MoneyTableEntry.Create("timestamp", info.lastUpdate)
		}
		entries[#entries + 1] = entry
	end

	return ns.MoneyTableCollection.Create(entries)
end

if ns then
	ns.MoneyTableConversion = export
end
return export
