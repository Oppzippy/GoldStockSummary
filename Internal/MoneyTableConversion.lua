---@class ns
local _, ns = ...

local date = date or os.date

-- storage format (TrackedMoney) > intermediary format (CharacterMoneyTable) -> csv/table

local export = {}

---@alias CharacterMoneyTable CharacterMoneyTableEntry[]

---@class CharacterMoneyTableEntry
---@field name string
---@field realm string
---@field copper number
---@field personalCopper number
---@field guildBankCopper? number
---@field lastUpdate? number

---@param characters table<string, TrackedCharacter>
---@param guilds? table<string, TrackedGuild>
---@return CharacterMoneyTable
function export.TrackedMoneyToCharacterMoneyTable(characters, guilds)
	local moneyTable = {}
	for nameAndRealm, info in next, characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")

		local totalCopper = info.copper
		local guildBankCopper
		if info.guild and guilds and guilds[info.guild] and guilds[info.guild].owner == nameAndRealm then
			guildBankCopper = guilds[info.guild].copper
			totalCopper = totalCopper + guildBankCopper
		end

		moneyTable[#moneyTable + 1] = {
			name = name,
			realm = realm,
			copper = totalCopper,
			guildBankCopper = guildBankCopper,
			personalCopper = info.copper,
			lastUpdate = info.lastUpdate,
		}
	end

	return moneyTable
end

if ns then
	ns.MoneyTableConversion = export
end
return export
