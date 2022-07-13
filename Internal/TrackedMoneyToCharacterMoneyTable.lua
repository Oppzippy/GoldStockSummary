---@class ns
local _, ns = ...

local date = date or os.date

-- storage format (TrackedMoney) > intermediary format (CharacterMoneyTable) -> csv/table

local function TrackedMoneyToCharacterMoneyTable(characters, guilds)
	local moneyTable = {}
	for nameAndRealm, info in next, characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")
		local lastUpdate = info.lastUpdate and date("%Y-%m-%d %I:%M:%S %p", info.lastUpdate)

		local totalCopper = info.copper
		local guildBankCopper
		if info.guild and guilds[info.guild] and guilds[info.guild].owner == nameAndRealm then
			guildBankCopper = guilds[info.guild].copper
			totalCopper = totalCopper + guildBankCopper
		end

		moneyTable[#moneyTable + 1] = {
			name = name,
			realm = realm,
			copper = totalCopper,
			guildBankCopper = guildBankCopper,
			personalCopper = info.copper,
			lastUpdate = lastUpdate,
		}
	end

	return moneyTable
end

return TrackedMoneyToCharacterMoneyTable
