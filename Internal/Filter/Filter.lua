---@class ns
local ns = select(2, ...)

local export = {}

---@class FilterConfiguration
---@field name string
---@field type "whitelist"|"blacklist"|"combinedFilter"
---@field listFilterType "characterList"|"pattern"
---@field characters? table<string, boolean>
---@field pattern? string
---@field childFilterIDs unknown[]

---@class Filter
---@field name string
local Filter = {}

---@param pool table<string, unknown>
---@return table<string, unknown> pool, table<string, unknown> accepted
function Filter:Filter(pool) end

local createWhitelist, createBlacklist, createCombinedFilter, createFilter

---@param config FilterConfiguration
---@param filterConfigurations table<unknown, FilterConfiguration>
---@param seenFilters? table<unknown, boolean>
---@return Filter? filter, string? error
function createFilter(config, filterConfigurations, seenFilters)
	assert(config.type, "configuration type must not be nil")
	if config.type == "whitelist" then
		return createWhitelist(config)
	elseif config.type == "blacklist" then
		return createBlacklist(config)
	elseif config.type == "combinedFilter" then
		return createCombinedFilter(config, filterConfigurations, seenFilters)
	end
	return nil, string.format("filter type %s not found", tostring(config.type))
end

---@param config FilterConfiguration
---@return Filter? filter, string? error
function createWhitelist(config)
	if config.listFilterType == "characterList" then
		return ns.CharacterWhitelistFilter.Create(config.name, config.characters or {}), nil
	elseif config.listFilterType == "pattern" then
		return ns.PatternWhitelistFilter.Create(config.name, config.pattern or ""), nil
	end
	return nil, string.format("unknown whitelist list filter type: %s", tostring(config.listFilterType))
end

---@param config FilterConfiguration
---@return Filter? filter, string? error
function createBlacklist(config)
	if config.listFilterType == "characterList" then
		return ns.CharacterBlacklistFilter.Create(config.name, config.characters or {}), nil
	elseif config.listFilterType == "pattern" then
		return ns.PatternBlacklistFilter.Create(config.name, config.pattern or ""), nil
	end
	return nil, string.format("unknown blacklist list filter type: %s", tostring(config.listFilterType))
end

---@param config FilterConfiguration
---@param filterConfigurations table<unknown, FilterConfiguration>
---@param seenFilters? table<unknown, boolean>
---@return Filter? filter, string? error
function createCombinedFilter(config, filterConfigurations, seenFilters)
	local childFilters = {}
	if not seenFilters then
		seenFilters = {}
	end
	if config.childFilterIDs then
		for i, id in ipairs(config.childFilterIDs) do
			if not filterConfigurations or not filterConfigurations[id] then
				return nil, string.format("filter \"%s\" references nonexistent filter", config.name)
			end
			if seenFilters[id] then
				return nil, string.format("filter loop found at filter \"%s\"", filterConfigurations[id].name)
			end
			-- This is basically a set of every filter in the filter call stack.
			-- As long as no filter is a child of itself, it's fine to use a filter more than once.
			seenFilters[id] = true
			local childFilter, err = createFilter(filterConfigurations[id], filterConfigurations, seenFilters)
			if err then
				return nil, err
			end
			childFilters[i] = childFilter
			seenFilters[id] = false
		end
	end
	return ns.CombinedFilter.Create(config.name, childFilters), nil
end

local hardDenyFilter = {
	Filter = function()
		return {}, {}
	end,
}
local hardAllowFilter = {
	Filter = function(_, pool)
		return {}, pool
	end
}

--- Filters can reference other filters, so they must all be created at once to make those connections
---@param filterConfigurations table<unknown, FilterConfiguration>
---@return table<unknown, Filter> filters, table<unknown, string> errors
function export.FromConfigurations(filterConfigurations)
	local filters = {}
	local errors = {}
	for id, configuration in next, filterConfigurations do
		-- When not a part of a combined filters, whitelists should remove everything from the pool that isn't whitelisted
		-- and blacklists should allow everything that isn't included in the backlist
		-- In combined filters, this behavior is undesired, so it must be handled as a special case
		local rawFilter, err = createFilter(configuration, filterConfigurations)
		if err then
			errors[id] = err
		else
			if configuration.type == "whitelist" then
				filters[id] = ns.CombinedFilter.Create(configuration.name, {
					rawFilter,
					hardDenyFilter,
				})
			elseif configuration.type == "blacklist" then
				filters[id] = ns.CombinedFilter.Create(configuration.name, {
					rawFilter,
					hardAllowFilter,
				})
			else
				filters[id] = rawFilter
			end
		end
	end
	return filters, errors
end

ns.Filter = export
