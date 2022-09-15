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

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function Filter:Filter(pool) end

local createWhitelist, createBlacklist, createCombinedFilter, createFilter

---@param config FilterConfiguration
---@param filterConfigurations table<unknown, FilterConfiguration>
---@param seenFilters? table<unknown, boolean>
---@return Filter
function createFilter(config, filterConfigurations, seenFilters)
	assert(config.type, "configuration type must not be nil")
	if config.type == "whitelist" then
		return createWhitelist(config)
	elseif config.type == "blacklist" then
		return createBlacklist(config)
	elseif config.type == "combinedFilter" then
		return createCombinedFilter(config, filterConfigurations, seenFilters)
	end
	error(string.format("filter type %s not found", tostring(config.type)))
end

---@param config FilterConfiguration
---@return Filter
function createWhitelist(config)
	if config.listFilterType == "characterList" then
		return ns.CharacterWhitelistFilter.Create(config.name, config.characters)
	elseif config.listFilterType == "pattern" then
		return ns.PatternWhitelistFilter.Create(config.name, config.pattern)
	end
	error(string.format("unknown whitelist list filter type: %s", tostring(config.listFilterType)))
end

---@param config FilterConfiguration
---@return Filter
function createBlacklist(config)
	if config.listFilterType == "characterList" then
		return ns.CharacterBlacklistFilter.Create(config.name, config.characters)
	elseif config.listFilterType == "pattern" then
		return ns.PatternBlacklistFilter.Create(config.name, config.pattern)
	end
	error(string.format("unknown blacklist list filter type: %s", tostring(config.listFilterType)))
end

---@param config FilterConfiguration
---@param filterConfigurations table<unknown, FilterConfiguration>
---@param seenFilters? table<unknown, boolean>
---@return Filter
function createCombinedFilter(config, filterConfigurations, seenFilters)
	local childFilters = {}
	if not seenFilters then
		seenFilters = {}
	end
	for i, id in ipairs(config.childFilterIDs) do
		if not filterConfigurations or not filterConfigurations[id] then
			error(string.format("filter \"%s\" references nonexistent filter", config.name))
		end
		if seenFilters[id] then
			error(string.format("filter loop found at filter \"%s\"", filterConfigurations[id].name))
		end
		seenFilters[id] = true
		childFilters[i] = createFilter(filterConfigurations[id], filterConfigurations, seenFilters)
	end
	return ns.CombinedFilter.Create(config.name, childFilters)
end

--- Filters can reference other filters, so they must all be created at once to make those connections
---@param filterConfigurations table<unknown, FilterConfiguration>
---@return table<unknown, Filter>
function export.FromConfigurations(filterConfigurations)
	local filters = {}
	for id, configuration in next, filterConfigurations do
		filters[id] = createFilter(configuration, filterConfigurations)
	end
	return filters
end

ns.Filter = export
