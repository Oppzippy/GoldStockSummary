---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceLocale = LibStub("AceLocale-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local L = AceLocale:GetLocale(addonName)

---@class FiltersTab
---@field characters table<string, unknown>
---@field filters table<unknown, FilterConfiguration>
local FiltersTab = {}
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
						FiltersTab.filters[#FiltersTab.filters + 1] = {
							name = name,
						}
						FiltersTab:Render()
					end,
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

local optionsTableName = addonName .. "-UI-FiltersTab"
AceConfig:RegisterOptionsTable(optionsTableName, FiltersTab.options)

---@return AceGUIWidget
function FiltersTab:Render()
	local args = {}
	for id in next, self.filters do
		args[tostring(id)] = self:RenderFilter(id)
	end
	self.options.args.filterSettings.args = args

	local target = AceGUI:Create("SimpleGroup")
	AceConfigDialog:Open(optionsTableName, target)
	return target
end

---@param filterID unknown
---@return AceConfigOptionsTable
function FiltersTab:RenderFilter(filterID)
	local filter = self.filters[filterID]
	local selectedRealm
	local group
	local function renderCharacterList()
		local args = {}
		if filter.characters then
			for nameAndRealm in next, filter.characters do
				local name, realm = strsplit("-", nameAndRealm)
				if not args[realm] then
					args[realm] = {
						type = "group",
						inline = true,
						name = realm,
						args = {},
					}
				end
				args[realm].args[name] = {
					type = "execute",
					name = name,
					desc = L.click_to_remove,
					func = function()
						filter.characters[nameAndRealm] = nil
						renderCharacterList()
					end,
				}
			end
		end
		group.args.characterList.args = args
	end

	local function isNotWhitelistOrBlacklist()
		return filter.type ~= "whitelist" and filter.type ~= "blacklist"
	end

	local function isNotCombinedFilter()
		return filter.type ~= "combinedFilter"
	end

	local function isNotCharacterListFilter()
		return isNotWhitelistOrBlacklist() or filter.listFilterType ~= "characterList"
	end

	local function isNotPatternFilter()
		return isNotWhitelistOrBlacklist() or filter.listFilterType ~= "pattern"
	end

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
				end,
				validate = function(_, newName)
					for _, otherFilter in next, self.filters do
						if otherFilter.name == newName and otherFilter ~= filter then
							return L.filter_already_exists:format(otherFilter.name)
						end
					end
					return true
				end,
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
				end,
				values = {
					whitelist = L.whitelist,
					blacklist = L.blacklist,
					combinedFilter = L.combined_filter,
				},
				sorting = { "whitelist", "blacklist", "combinedFilter" },
				order = 2,
			},

			-----------------------------------------------------------
			-- Whitelist/Blacklist Options
			listFilterType = {
				type = "select",
				name = L.list_type,
				hidden = isNotWhitelistOrBlacklist,
				get = function()
					return filter.listFilterType
				end,
				set = function(_, listFilterType)
					filter.listFilterType = listFilterType
				end,
				values = {
					characterList = L.character_list,
					pattern = L.pattern,
				},
				sorting = { "characterList", "pattern" },
				order = 3,
			},

			-----------------------------------------------------------
			-- Character List
			addCharacterHeader = {
				type = "header",
				name = L.add_character,
				hidden = isNotCharacterListFilter,
				order = 3.9,
			},
			addCharacterRealm = {
				type = "select",
				name = L.realm,
				hidden = isNotCharacterListFilter,
				get = function()
					return selectedRealm
				end,
				set = function(_, realm)
					selectedRealm = realm
				end,
				values = function()
					local realms = {}
					for nameAndRealm in next, self.characters do
						if not filter.characters or not filter.characters[nameAndRealm] then
							local _, realm = strsplit("-", nameAndRealm)
							realms[realm] = realm
						end
					end
					return realms
				end,
				order = 4,
			},
			addCharacter = {
				type = "select",
				name = L.realm,
				hidden = isNotCharacterListFilter,
				values = function(...)
					local characters = {}
					for nameAndRealm in next, self.characters do
						local character, realm = strsplit("-", nameAndRealm)
						if selectedRealm == realm and (not filter.characters or not filter.characters[nameAndRealm]) then
							characters[nameAndRealm] = character
						end
					end
					return characters
				end,
				set = function(_, nameAndRealm)
					if not filter.characters then
						filter.characters = {}
					end
					filter.characters[nameAndRealm] = true
					renderCharacterList()
				end,
				order = 5,
			},
			characterList = {
				type = "group",
				inline = true,
				name = L.characters,
				hidden = isNotCharacterListFilter,
				order = 6,
				args = {},
			},

			-----------------------------------------------------------
			-- Pattern
			pattern = {
				hidden = isNotPatternFilter,
				type = "input",
				name = L.pattern,
				width = "full",
				order = 7,
				get = function()
					return filter.pattern
				end,
				set = function(_, pattern)
					filter.pattern = pattern
				end,
			},

			-----------------------------------------------------------
			-- Combined Filter
			combinedFilter = {
				type = "group",
				inline = true,
				name = L.combined_filter,
				hidden = isNotCombinedFilter,
				order = 8,
				args = {},
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
					self:Render()
				end,
				order = 99999,
			}
		},
	}
	renderCharacterList()
	return group
end

ns.FiltersTab = FiltersTab
