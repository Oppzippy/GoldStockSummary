---@class ns
local ns = select(2, ...)

---@param trackedMoney TrackedMoney
---@return MoneyTable
local function Characters(trackedMoney)
	local entries = {}
	for nameAndRealm, info in next, trackedMoney.characters do
		local characterCopper = trackedMoney:GetCharacterCopper(nameAndRealm)

		local entry = {
			name = info.name,
			realm = info.realm,
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
