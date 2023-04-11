---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CombinedFilterFactory: FilterFactory
local CombinedFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "combinedFilter",
	localizedName = L.combined_filter,
}

---@class CombinedFilterConfiguration
---@field childFilterIDs? unknown[]
---@field childFilters? Filter[]

---@param filterName string
---@param config CombinedFilterConfiguration
---@return Filter
function CombinedFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool, trackedMoney)
		local allowed = {}

		for _, filter in ipairs(config.childFilters) do
			local addToAllowed
			pool, addToAllowed = filter:Filter(pool, trackedMoney)
			for name in next, addToAllowed do
				allowed[name] = true
			end
		end

		return pool, allowed
	end)
end

---@return CombinedFilterConfiguration
function CombinedFilterFactory:DefaultConfiguration()
	return {
		childFilterIDs = {},
	}
end

-- Unique value to use as a table key
local removeSymbol = {}

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CombinedFilterFactory:OptionsTable(config, db)
	local function renderFilterChain()
		local values = {
			[removeSymbol] = L.remove_filter,
		}
		local order = {}
		for id, f in next, db.profile.filters do
			-- A filter can not be a child of itself. This prevents direct children, but grandchildren and so on will error.
			if f ~= config then
				values[id] = f.name
				order[#order + 1] = id
			end
		end
		table.sort(order, function(a, b)
			return db.profile.filters[a].name < db.profile.filters[b].name
		end)
		local orderWithRemove = ns.Util.CloneTableShallow(order)
		orderWithRemove[#orderWithRemove + 1] = removeSymbol

		local args = {}
		local function renderArgs()
			local typeConfig = config.typeConfig[self.type]
			for i = 1, #typeConfig.childFilterIDs do
				args[tostring(i)] = {
					type = "select",
					name = L.filter_x:format(i),
					values = values,
					sorting = orderWithRemove,
					get = function()
						return typeConfig.childFilterIDs[i]
					end,
					set = function(_, val)
						if val == removeSymbol then
							table.remove(typeConfig.childFilterIDs, i)
							wipe(args)
							renderArgs()
						else
							typeConfig.childFilterIDs[i] = val
						end
						LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
					end,
					order = i,
				}
			end
			args.add = {
				type = "select",
				name = L.add_filter,
				values = values,
				sorting = order,
				get = function()
				end,
				set = function(_, val)
					typeConfig.childFilterIDs[#typeConfig.childFilterIDs + 1] = val
					wipe(args)
					renderArgs()
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
				order = 999999,
			}
		end

		renderArgs()

		return args
	end
	return {
		args = renderFilterChain(),
	}
end

ns.FilterFactoryRegistry:Register(CombinedFilterFactory)
