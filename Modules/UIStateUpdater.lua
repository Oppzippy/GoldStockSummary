---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

local GoldStockSummary = AceAddon:GetAddon(addonName)
---@cast GoldStockSummary GoldStockSummary

---@class UIStateUpdaterModule : AceEvent-3.0
local module = GoldStockSummary:NewModule("UIStateUpdater", "AceEvent-3.0")

function module:OnEnable()
	self.db = ns.db
	self:SetMoneyStore()
	self:OnFiltersChanged()

	self:RegisterMessage("GoldStockSummary_CharacterMoneyUpdated", "OnCharacterMoneyUpdated")
	self:RegisterMessage("GoldStockSummary_GuildMoneyUpdated", "OnGuildMoneyUpdated")
	self:RegisterMessage("GoldStockSummary_FiltersChanged", "OnFiltersChanged")
end

function module:SetMoneyStore()
	local characters = {}
	for name, trackedCharacter in next, self.db.global.characters do
		characters[name] = ns.Util.CloneTableShallow(trackedCharacter)
	end
	ns.MoneyStore:Dispatch({
		type = "setCharacters",
		characters = ns.Util.CloneTableShallow(characters),
	})

	local guilds = {}
	for name, trackedGuild in next, self.db.global.guilds do
		guilds[name] = ns.Util.CloneTableShallow(trackedGuild)
	end
	ns.MoneyStore:Dispatch({
		type = "setGuilds",
		guilds = guilds,
	})
end

function module:OnCharacterMoneyUpdated(_, name)
	ns.MoneyStore:Dispatch({
		type = "updateCharacter",
		name = name,
		character = self.db.global.characters[name],
	})
end

function module:OnGuildMoneyUpdated(_, name)
	ns.MoneyStore:Dispatch({
		type = "updateGuild",
		name = name,
		guild = self.db.global.guilds[name],
	})
end

function module:OnFiltersChanged()
	local filters, errors = ns.Filter.FromConfigurations(self.db.profile.filters)
	ns.FilterStore:Dispatch({
		type = "updateFilterConfigurations",
		filters = filters,
	})
	for id, err in next, errors do
		GoldStockSummary:Printf("Error creating filter \"%s\": %s", tostring(self.db.profile.filters[id].name), err)
	end
end
