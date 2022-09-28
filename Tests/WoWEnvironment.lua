function GetLocale()
	return "enUS"
end

strmatch = string.match

local namespace = {}
function DoWoWFile(path)
	local func, err = loadfile(path)
	if err then
		error(err)
	end
	if not func then
		error(string.format("error loading %s: function is nil", path))
	end
	func("GoldStockSummary", namespace)
end

--Libraries
DoWoWFile("Libs/LibStub/LibStub.lua")
DoWoWFile("Libs/AceLocale-3.0/AceLocale-3.0.lua")
DoWoWFile("Libs/json.lua/json.lua")

-- Locales
DoWoWFile("Locales/enUS.lua")

--- Internal
DoWoWFile("DB/Defaults.lua")
DoWoWFile("DB/Migrations/Global/001-NormalizeRealmNames.lua")
DoWoWFile("Internal/Filter/Filter.lua")
DoWoWFile("Internal/Filter/CharacterBlacklistFilter.lua")
DoWoWFile("Internal/Filter/CharacterWhitelistFilter.lua")
DoWoWFile("Internal/Filter/CombinedFilter.lua")
DoWoWFile("Internal/Filter/PatternWhitelistFilter.lua")
DoWoWFile("Internal/Filter/PatternBlacklistFilter.lua")
DoWoWFile("Internal/MoneyTable/Namespace.lua")
DoWoWFile("Internal/MoneyTable/Factory/Characters.lua")
DoWoWFile("Internal/MoneyTable/Factory/Realms.lua")
DoWoWFile("Internal/MoneyTable/To/ToCSV.lua")
DoWoWFile("Internal/MoneyTable/To/ToJSON.lua")
DoWoWFile("Internal/MoneyTable/To/ToScrollingTable.lua")
DoWoWFile("Internal/MoneyTable/MoneyTable.lua")
DoWoWFile("Internal/TrackedMoney.lua")
DoWoWFile("Internal/Util.lua")
