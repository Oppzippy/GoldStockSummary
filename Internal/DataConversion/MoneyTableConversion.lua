---@class ns
local _, ns = ...

local date = date or os.date

-- storage format (TrackedMoney) > intermediary format (CharacterMoneyTable) -> csv/table

local export = {}

---@alias CharacterMoneyTable CharacterMoneyTableEntry[]

local characterMoneyTableEntryFieldOrder = {
	"name",
	"realm",
	"copper",
	"gold",
	"personalCopper",
	"personalGold",
	"guildBankCopper",
	"guildBankGold",
	"lastUpdateTimestamp",
	"lastUpdate",
}
---@class CharacterMoneyTableEntry
---@field name string
---@field realm string
---@field copper number
---@field gold number
---@field personalCopper number
---@field personalGold number
---@field guildBankCopper? number
---@field guildBankGold? number
---@field lastUpdateTimestamp? integer
---@field lastUpdate? string

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

		---@type CharacterMoneyTableEntry
		local entry = {
			name = name,
			realm = realm,
			copper = totalCopper,
			guildBankCopper = guildBankCopper,
			personalCopper = info.copper,
			lastUpdateTimestamp = info.lastUpdate,
		}

		entry.gold = entry.copper / 10000 -- COPPER_PER_GOLD
		entry.personalGold = entry.personalCopper / 10000 -- COPPER_PER_GOLD
		entry.guildBankGold = entry.guildBankCopper / 10000 -- COPPER_PER_GOLD

		local lastUpdate = date("%Y-%m-%d %I:%M %p", entry.lastUpdateTimestamp)
		if type(lastUpdate) == "string" then
			entry.lastUpdate = lastUpdate
		else
			error("expected string")
		end


		moneyTable[#moneyTable + 1] = entry
	end

	return moneyTable
end

if ns then
	ns.MoneyTableConversion = export
	ns.CharacterMoneyTableEntryFieldOrder = characterMoneyTableEntryFieldOrder
end
return export
