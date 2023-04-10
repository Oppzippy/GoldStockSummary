function GetLocale()
	return "enUS"
end

function geterrorhandler()
	return error
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
DoWoWFile("DB/Migrations/Profile/001-MigrateFilters.lua")
DoWoWFile("DB/Migrations/Profile/002-MigrateFilters.lua")
DoWoWFile("DB/Migrations/Profile/003-AddTypeConfigDefaults.lua")
DoWoWFile("Internal/Filter.lua")
DoWoWFile("Internal/FilterRegistry.lua")
DoWoWFile("Internal/Filter/CharacterBlacklistFilter.lua")
DoWoWFile("Internal/Filter/CharacterWhitelistFilter.lua")
DoWoWFile("Internal/Filter/CombinedFilter.lua")
DoWoWFile("Internal/Filter/CharacterPatternWhitelistFilter.lua")
DoWoWFile("Internal/Filter/CharacterPatternBlacklistFilter.lua")
DoWoWFile("Internal/Filter/CharacterCopperFilter.lua")
DoWoWFile("Internal/MoneyTable/Namespace.lua")
DoWoWFile("Internal/MoneyTable/Factory/Characters.lua")
DoWoWFile("Internal/MoneyTable/Factory/Realms.lua")
DoWoWFile("Internal/MoneyTable/Factory/RealmsWithCombinedFactions.lua")
DoWoWFile("Internal/MoneyTable/To/ToCSV.lua")
DoWoWFile("Internal/MoneyTable/To/ToJSON.lua")
DoWoWFile("Internal/MoneyTable/To/ToScrollingTable.lua")
DoWoWFile("Internal/MoneyTable/MoneyTable.lua")
DoWoWFile("Internal/TrackedMoney.lua")
DoWoWFile("Internal/Util.lua")
