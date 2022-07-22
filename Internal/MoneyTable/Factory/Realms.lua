---@class ns
local _, ns = ...

---@param trackedMoney TrackedMoney
---@return MoneyTable
local function Realms(trackedMoney)
	local keyedEntries = {}
	for name, realm, nameAndRealm in trackedMoney:IterateCharacters() do
		local trackedCharacter = trackedMoney.characters[nameAndRealm]
		local key = realm .. trackedCharacter.faction
		if not keyedEntries[key] then
			keyedEntries[key] = {
				realm = realm,
				faction = trackedCharacter.faction,
				totalMoney = 0,
				personalMoney = 0,
				guildBankMoney = 0,
			}
		end
		local row = keyedEntries[key]
		local characterCopper = trackedMoney:GetCharacterCopper(name, realm)
		row.totalMoney = row.totalMoney + characterCopper.totalCopper
		row.personalMoney = row.personalMoney + characterCopper.personalCopper
		row.guildBankMoney = row.guildBankMoney + (characterCopper.guildCopper or 0)
	end
	local entries = {}
	for _, row in next, keyedEntries do
		entries[#entries + 1] = row
	end

	return ns.MoneyTable.Create({
		realm = "string",
		faction = "faction",
		totalMoney = "copper",
		personalMoney = "copper",
		guildBankMoney = "copper",
	}, entries)
end

---@class ns.MoneyTable.Factory
local Factory = ns.MoneyTable.Factory
Factory.Realms = Realms
