---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

---@class CharacterBlacklistFilterFactory: FilterFactory
local CharacterBlacklistFilterFactory = {
	type = "characterBlacklist",
	localizedName = L.character_blacklist,
	terminus = "allow",
}

---@class CharacterBlacklistFilterConfiguration
---@field characters table<string, boolean>

---@param filterName string
---@param config CharacterBlacklistFilterConfiguration
---@return Filter
function CharacterBlacklistFilterFactory:Create(filterName, config)
	return ns.Filter.Create(filterName, function(pool)
		local newPool = {}
		for name, trackedCharacter in next, pool do
			if not config.characters[name] then
				newPool[name] = trackedCharacter
			end
		end
		return newPool, {}
	end)
end

---@return CharacterBlacklistFilterConfiguration
function CharacterBlacklistFilterFactory:DefaultConfiguration()
	return {
		characters = {},
	}
end

---@param config FilterConfiguration
---@param db AceDBObject-3.0
---@return AceConfigOptionsTable
function CharacterBlacklistFilterFactory:OptionsTable(config, db)
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
						if not typeConfig.characters or not typeConfig.characters[nameAndRealm] then
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
						if selectedRealm == realm and (not typeConfig.characters or not typeConfig.characters[nameAndRealm]) then
							realmCharacters[nameAndRealm] = character
						end
					end
					return realmCharacters
				end,
				set = function(_, nameAndRealm)
					local typeConfig = config.typeConfig[config.type]
					if not typeConfig.characters then
						typeConfig.characters = {}
					end
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
		if characters then
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
		end
		optionsTable.args.characterList.args = args
	end
	renderCharacterList()

	return optionsTable
end

ns.FilterRegistry:Register(CharacterBlacklistFilterFactory)
