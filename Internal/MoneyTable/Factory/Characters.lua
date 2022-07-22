---@class ns
local _, ns = ...

---@param trackedMoney TrackedMoney
---@return MoneyTable
local function Characters(trackedMoney)
	local entries = {}
	for nameAndRealm, info in next, trackedMoney.characters do
		local name, realm = string.match(nameAndRealm, "(.*)-(.*)")

		local characterCopper = trackedMoney:GetCharacterCopper(name, realm)

		local entry = {
			name = name,
			realm = realm,
			faction = info.faction,
			totalMoney = characterCopper.totalCopper,
			personalMoney = characterCopper.personalCopper,
			guildBankMoney = characterCopper.guildCopper,
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

---@class ns.MoneyTable.Factory
local Factory = ns.MoneyTable.Factory
Factory.Characters = Characters
