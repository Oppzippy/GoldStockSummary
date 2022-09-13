---@class ns
local ns = select(2, ...)

local function getState()
	local trackedMoney = ns.TrackedMoney.Create(ns.db.global.characters, ns.db.global.guilds)
	local total = 0
	local personalTotal = 0
	local guildBankTotal = 0
	for name, realm in trackedMoney:IterateCharacters() do
		local characterCopper = trackedMoney:GetCharacterCopper(name, realm)
		total = total + characterCopper.totalCopper
		personalTotal = personalTotal + characterCopper.personalCopper
		guildBankTotal = guildBankTotal + (characterCopper.guildCopper or 0)
	end
	return {
		total = total,
		personalTotal = personalTotal,
		guildBankTotal = guildBankTotal,
	}
end

local function reducer(action)
	if action == "update" then
		return getState()
	end
	error("unknown action")
end

ns.TotalMoneyStore = ns.LazyStore.Create(reducer, getState)
