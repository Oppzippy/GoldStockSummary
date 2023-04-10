---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterWhitelistFilterFactory: FilterFactory
local CharacterWhitelistFilterFactory = {
	---@type AceConfigOptionsTable
	options = {},
	type = "characterWhitelist",
	localizedName = L.character_whitelist,
	terminus = "deny",
}

---@class CharacterWhitelistFilterConfiguration
---@field characters table<string, boolean>

---@param filterName string
---@param config CharacterWhitelistFilterConfiguration
---@return Filter
function CharacterWhitelistFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool)
		local newPool = {}
		local allowed = {}
		for name, trackedCharacter in next, pool do
			if config.characters[name] then
				allowed[name] = trackedCharacter
			else
				newPool[name] = trackedCharacter
			end
		end
		return newPool, allowed
	end)
end

---@return CharacterWhitelistFilterConfiguration
function CharacterWhitelistFilterFactory:DefaultConfiguration()
	return {
		characters = {},
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterWhitelistFilterFactory:OptionsTable(config, db)
	---@type fun()
	local renderCharacterList
	local selectedRealm
	local optionsTable = {
		type = "group",
		args = {
			addCharacterHeader = {
				type = "header",
				name = L.add_character,
				order = 3.9,
			},
			addCharacterRealm = {
				type = "select",
				name = L.realm,
				get = function()
					return selectedRealm
				end,
				set = function(_, realm)
					selectedRealm = realm
				end,
				values = function()
					local realms = {}
					local typeConfig = config.typeConfig[config.type]
					for nameAndRealm in next, db.global.characters do
						if not typeConfig.characters[nameAndRealm] then
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
				values = function(...)
					local realmCharacters = {}
					local typeConfig = config.typeConfig[config.type]
					for nameAndRealm in next, db.global.characters do
						local character, realm = strsplit("-", nameAndRealm)
						if selectedRealm == realm and not typeConfig.characters[nameAndRealm] then
							realmCharacters[nameAndRealm] = character
						end
					end
					return realmCharacters
				end,
				set = function(_, nameAndRealm)
					local typeConfig = config.typeConfig[config.type]
					typeConfig.characters[nameAndRealm] = true
					renderCharacterList()
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
				order = 5,
			},
			characterList = {
				type = "group",
				inline = true,
				name = L.characters,
				order = 6,
				args = {},
			}
		},
	}

	renderCharacterList = function()
		local args = {}
		local characters = config.typeConfig[self.type].characters
		for nameAndRealm in next, characters do
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
					characters[nameAndRealm] = nil
					renderCharacterList()
					LibStub("AceEvent-3.0"):SendMessage("GoldStockSummary_FiltersChanged")
				end,
			}
		end
		optionsTable.args.characterList.args = args
	end
	renderCharacterList()

	return optionsTable
end

ns.FilterRegistry:Register(CharacterWhitelistFilterFactory)
