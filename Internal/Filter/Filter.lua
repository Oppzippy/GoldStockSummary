---@class ns
local ns = select(2, ...)

local export = {}

---@class FilterConfiguration
---@field name string
---@field type "characterWhitelist"|"characterBlacklist"|"combinedFilter"|"characterPatternWhitelist"|"characterPatternBlacklist"|"characterCopper"

---@class Filter
---@field name string
local Filter = {}

---@param pool table<string, TrackedCharacter>
---@return table<string, TrackedCharacter> pool, table<string, TrackedCharacter> accepted
function Filter:Filter(pool) return pool, {} end

local constructors = {
	---@param config CharacterWhitelistFilterConfiguration
	characterWhitelist = function(config)
		return ns.CharacterWhitelistFilter.Create(config.name, config.characters or {}), nil
	end,
	---@param config CharacterPatternWhitelistFilterConfiguration
	characterPatternWhitelist = function(config)
		return ns.CharacterPatternWhitelistFilter.Create(config.name, config.pattern or ""), nil
	end,
	---@param config CharacterBlacklistFilterConfiguration
	characterBlacklist = function(config)
		return ns.CharacterBlacklistFilter.Create(config.name, config.characters or {}), nil
	end,
	---@param config CharacterPatternBlacklistFilterConfiguration
	characterPatternBlacklist = function(config)
		return ns.CharacterPatternBlacklistFilter.Create(config.name, config.pattern or ""), nil
	end,
	---@param config CharacterCopperFilterConfiguration
	characterCopper = function(config)
		return ns.CharacterCopperFilter.Create(config.name, config.sign, config.copper), nil
	end,
}
local createCombinedFilter

---@param config FilterConfiguration
---@param filterConfigurations table<unknown, FilterConfiguration>
---@param seenFilters? table<unknown, boolean>
---@return Filter? filter, string? error
local function createFilter(config, filterConfigurations, seenFilters)
	assert(config.type, "configuration type must not be nil")
	if config.type == "combinedFilter" then
		---@cast config CombinedFilterConfiguration
		return createCombinedFilter(config, filterConfigurations, seenFilters)
	else
		local constructor = constructors[config.type]
		if constructor then
			-- Type is checked by indexing the constructors table
			---@diagnostic disable-next-line: param-type-mismatch
			return constructor(config)
		end
	end
	return nil, string.format("filter type %s not found", tostring(config.type))
end

---@param config CombinedFilterConfiguration
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
---@param filterConfigurations table<any, FilterConfiguration>
---@return table<any, Filter> filters, table<any, string> errors
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
			if configuration.type == "combinedFilter" then
				filters[id] = rawFilter
			elseif configuration.type == "characterBlacklist" or configuration.type == "characterPatternBlacklist" then
				filters[id] = ns.CombinedFilter.Create(configuration.name, {
					rawFilter,
					hardAllowFilter,
				})
			else
				filters[id] = ns.CombinedFilter.Create(configuration.name, {
					rawFilter,
					hardDenyFilter,
				})
			end
		end
	end
	return filters, errors
end

ns.Filter = export
