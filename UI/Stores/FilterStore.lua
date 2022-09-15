---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale(addonName)

local defaultFilters = ns.Filter.FromConfigurations({
	allowAll = {
		name = L.allow_all,
		type = "whitelist",
		listFilterType = "pattern",
		pattern = ".",
	},
	denyAll = {
		name = L.deny_all,
		type = "blacklist",
		listFilterType = "pattern",
		pattern = ".",
	},
})

local actions = {
	setFilters = function(_, action)
		local filters = ns.Filter.FromConfigurations(action.configuration)
		for id, filter in next, defaultFilters do
			filters[id] = filter
		end
		return filters
	end,
}

local function reducer(state, action)
	local actionFunc = actions[action.type]
	if actionFunc then
		return actionFunc(state, action)
	end
	error(string.format("unknown action: %s", action.type))
end

ns.FilterStore = ns.Store.Create(reducer, defaultFilters)