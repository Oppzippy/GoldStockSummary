---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale(addonName)

local optionsTableName = addonName .. "-UI-FiltersTab"

---@class FiltersTab : AceEvent-3.0
---@field characters table<string, unknown>
---@field filters table<unknown, FilterConfiguration>
local FiltersTab = {}
AceEvent:Embed(FiltersTab)

---@type AceConfigOptionsTable
FiltersTab.options = {
	type = "group",
	name = L.filters,
	childGroups = "tab",
	args = {
		newFilter = {
			type = "group",
			name = L.new_filter,
			order = 1,
			args = {
				name = {
					type = "input",
					name = L.name,
					width = "full",
					order = 1,
					set = function(_, name)
						local defaultType = "characterWhitelist"
						FiltersTab.filters[#FiltersTab.filters + 1] = {
							name = name,
							type = defaultType,
							typeConfig = {
								[defaultType] = ns.FilterFactoryRegistry:DefaultConfiguration(defaultType),
							},
						}
						FiltersTab:RenderFilters()
						AceConfigDialog:SelectGroup(optionsTableName, "filterSettings", tostring(#FiltersTab.filters))
						FiltersTab:FireFiltersChanged()
					end,
					validate = function(_, newName)
						for _, otherFilter in next, FiltersTab.filters do
							if otherFilter.name == newName then
								return L.filter_already_exists:format(otherFilter.name)
							end
						end
						return true
					end,
				},
				help = {
					type = "description",
					order = 2,
					name = L.new_filter_help,
					fontSize = "medium",
				},
			},
		},
		filterSettings = {
			type = "group",
			name = L.filter_settings,
			childGroups = "select",
			order = 2,
			args = {},
		},
	},
}

AceConfig:RegisterOptionsTable(optionsTableName, FiltersTab.options)

---@private
function FiltersTab:FireFiltersChanged()
	self:SendMessage("GoldStockSummary_FiltersChanged")
end

---@return AceGUIWidget
function FiltersTab:Render()
	self:RenderFilters()

	local target = AceGUI:Create("SimpleGroup")
	AceConfigDialog:Open(optionsTableName, target)
	return target
end

---@private
function FiltersTab:RenderFilters()
	local args = {}
	for id in next, self.filters do
		args[tostring(id)] = self:RenderFilter(id)
	end
	self.options.args.filterSettings.args = args
end

---@private
---@param filterID unknown
---@return AceConfigOptionsTable
function FiltersTab:RenderFilter(filterID)
	local filter = self.filters[filterID]

	local group
	group = {
		type = "group",
		name = filter.name,
		order = 1,
		args = {
			-----------------------------------------------------------
			-- General
			name = {
				type = "input",
				name = L.name,
				get = function()
					return filter.name
				end,
				set = function(_, name)
					filter.name = name
					group.name = name
					self:FireFiltersChanged()
				end,
				validate = function(_, newName)
					for _, otherFilter in next, self.filters do
						if otherFilter.name == newName and otherFilter ~= filter then
							return L.filter_already_exists:format(otherFilter.name)
						end
					end
					return true
				end,
				width = 1.5,
				order = 1,
			},
			type = {
				type = "select",
				name = L.type,
				get = function()
					return filter.type
				end,
				set = function(_, type)
					filter.type = type
					if not filter.typeConfig[type] then
						filter.typeConfig[type] = ns.FilterFactoryRegistry:DefaultConfiguration(type)
					end
					self:RenderFilters()
					self:FireFiltersChanged()
				end,
				values = {
					characterWhitelist = L.character_whitelist,
					characterPatternWhitelist = L.character_pattern_whitelist,
					characterBlacklist = L.character_blacklist,
					characterPatternBlacklist = L.character_pattern_blacklist,
					copper = L.money,
					combinedFilter = L.combined_filter,
				},
				sorting = {
					"characterWhitelist",
					"characterPatternWhitelist",
					"characterBlacklist",
					"characterPatternBlacklist",
					"copper",
					"combinedFilter",
				},
				width = 1.5,
				order = 2,
			},
			-----------------------------------------------------------
			-- Options for specific filter types
			typeConfig = {
				type = "group",
				name = ns.FilterFactoryRegistry:LocalizedName(filter.type),
				inline = true,
				order = 2.01,
				args = ns.FilterFactoryRegistry:OptionsTable(filter).args,
			},
			-----------------------------------------------------------
			-- Delete
			delete = {
				type = "execute",
				name = L.delete,
				confirm = true,
				confirmText = L.delete_are_you_sure:format(filter.name),
				width = "full",
				func = function()
					self.filters[filterID] = nil
					self:RenderFilters()
					self:FireFiltersChanged()
				end,
				order = 99999,
			},
		},
	}
	return group
end

ns.FiltersTab = FiltersTab
