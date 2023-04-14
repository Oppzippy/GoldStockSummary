---@class ns
local ns = select(2, ...)

---@class FilterFactory
---@field Create fun(self: FilterFactory, name: string, action: FilterAction, config: table): Filter
---@field OptionsTable fun(self: FilterFactory, config: FilterConfiguration, db: AceDBObject-3.0): AceConfigOptionsTable
---@field DefaultConfiguration fun(self: FilterFactory): table
---@field localizedName string

---@class FilterRegistry
local FilterFactoryRegistry = {
	---@type table<string, FilterFactory>
	factories = {},
}
ns.FilterFactoryRegistry = FilterFactoryRegistry

function FilterFactoryRegistry:Register(filter)
	self.factories[filter.type] = filter
end

---@class FilterConfiguration
---@field type string
---@field name string
---@field action FilterAction
---@field typeConfig table<string, table>

---@generic T
---@param configurations table<T, FilterConfiguration>
---@return Filter[], string[]
function FilterFactoryRegistry:Create(configurations)
	local filters = {}
	local errors = {}
	for id in next, configurations do
		local filter, error = self:CreateOne(configurations, id, {})
		filters[id] = filter
		errors[id] = error
	end
	return filters, errors
end

---@param config FilterConfiguration
---@return AceConfigOptionsTable
function FilterFactoryRegistry:OptionsTable(config)
	return self.factories[config.type]:OptionsTable(config, ns.db)
end

---@param filterType string
---@return string
function FilterFactoryRegistry:LocalizedName(filterType)
	return self.factories[filterType].localizedName
end

---@param filterType string
---@return table
function FilterFactoryRegistry:DefaultConfiguration(filterType)
	return self.factories[filterType]:DefaultConfiguration()
end

local denyAllFilter = ns.Filter.Create("Deny All", "allow", function(pool)
	return {}, {}
end)
local allowAllFilter = ns.Filter.Create("Allow All", "allow", function(pool)
	return {}, pool
end)

---@private
---@generic T
---@param configurations table<T, FilterConfiguration>
---@param id T
---@param seenIds table<T, boolean>
---@return Filter?, string?
function FilterFactoryRegistry:CreateOne(configurations, id, seenIds)
	local config = configurations[id]
	if not config then
		return nil, string.format("Filter with id %s does not exist", tostring(id))
	end

	if config.type == "combinedFilter" then
		local childFilters = {}
		if seenIds[id] then
			return nil, string.format("filter loop found at filter \"%s\"", config.name)
		end
		seenIds[id] = true
		local childFilterIDs = config.typeConfig.combinedFilter.childFilterIDs
		if childFilterIDs then
			for i, childId in ipairs(config.typeConfig.combinedFilter.childFilterIDs) do
				local filter, error = self:CreateOne(configurations, childId, seenIds)
				if error then
					return nil, error
				end
				childFilters[i] = filter
			end
		end
		seenIds[id] = nil
		config = {
			name = config.name,
			type = config.type,
			action = config.action,
			typeConfig = {
				[config.type] = {
					childFilters = childFilters
				},
			},
		}
	end
	local filterFactory = self.factories[config.type]
	if filterFactory then
		local filter = filterFactory:Create(
			config.name,
			config.action,
			config.typeConfig[config.type] or filterFactory:DefaultConfiguration()
		)
		local filterChain = { filter }
		-- Default action is allow, so we only need to cover the deny case
		-- If this is a top level filter and not a chlid of combined filter, we're done, so the filter should be terminated
		if not next(seenIds) then
			if config.action == "deny" or config.action == "denyExcept" then
				filterChain[#filterChain + 1] = allowAllFilter
			elseif config.action == "allow" or config.action == "allowExcept" then
				filterChain[#filterChain + 1] = denyAllFilter
			end
		end
		if filterChain[2] then
			filter = self:CombineFilters(filter.name, filterChain)
		end
		return filter
	end
	return nil, string.format("filter factory for type \"%s\" does not exist", config.type or "UNKNOWN")
end

---@private
---@param name string
---@param filters Filter[]
---@return Filter
function FilterFactoryRegistry:CombineFilters(name, filters)
	return self.factories["combinedFilter"]:Create(name, "allow", {
		childFilters = filters,
	})
end
