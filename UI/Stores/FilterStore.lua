---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale(addonName)

local defaultFilters = ns.FilterFactoryRegistry:Create({
	allowAll = {
		name = L.allow_all,
		type = "characterPattern",
		action = "allow",
		typeConfig = {
			characterPattern = {
				pattern = ".",
			},
		},
	},
})

local actions = {
	updateFilterConfigurations = function(_, action)
		local filters = ns.Util.CloneTableShallow(action.filters)
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
ns.UIFramework:RegisterGlobalStore(ns.FilterStore)
