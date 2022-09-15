---@class ns
local ns = select(2, ...)

local defaultFilters = ns.Filter.FromConfigurations({
	allowAll = {
		type = "whitelist",
		listFilterType = "pattern",
		pattern = ".",
	},
	denyAll = {
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
	deleteFilter = function(state, action)
		state.filters[action.id] = nil
		return state
	end,
}

local function reducer(state, action)
	local actionFunc = actions[action.type]
	if actionFunc then
		return actionFunc(state, action)
	end
	error(string.format("unknown action: %s", action.type))
end

ns.MoneyStore = ns.Store.Create(reducer, defaultFilters)
