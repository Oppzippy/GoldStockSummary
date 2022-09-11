---@class ns
local ns = select(2, ...)

---@class FilterConfiguration
---@field name string
---@field type "whitelist"|"blacklist"|"combinedFilter"
---@field listFilterType "characterList"|"pattern"
---@field characters? table<string, boolean>
---@field pattern? string
---@field childFilterIDs unknown[]

---@class Filter
local Filter = {}

---@param pool table<string, boolean>
---@return table<string, boolean> pool, table<string, boolean> accepted
function Filter:Filter(pool) end

local export = {}

---@param config FilterConfiguration
---@param filterConfigurations? table<unknown, FilterConfiguration>
---@return Filter
local function createFilterFromConfiguration(config, filterConfigurations, seenFilters)
	assert(config.type, "configuration type must not be nil")
	if config.type == "whitelist" then
		if config.listFilterType == "characterList" then
			return ns.CharacterWhitelistFilter.Create(config.characters)
		elseif config.listFilterType == "pattern" then
			return ns.PatternWhitelistFilter.Create(config.pattern)
		end
	elseif config.type == "blacklist" then
		if config.listFilterType == "characterList" then
			return ns.CharacterBlacklistFilter.Create(config.characters)
		elseif config.listFilterType == "pattern" then
			return ns.PatternBlacklistFilter.Create(config.pattern)
		end
	elseif config.type == "combinedFilter" then
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
			childFilters[i] = createFilterFromConfiguration(filterConfigurations[id], filterConfigurations, seenFilters)
		end
		return ns.CombinedFilter.Create(config.name, childFilters)
	end
	error(string.format("filter type %s not found, list type %s", config.type, config.listFilterType or ""))
end

---@param config FilterConfiguration
---@param filterConfigurations? table<unknown, FilterConfiguration>
---@return Filter
function export.FromConfiguration(config, filterConfigurations)
	return createFilterFromConfiguration(config, filterConfigurations)
end

ns.Filter = export
