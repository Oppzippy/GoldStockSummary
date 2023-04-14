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
DoWoWFile("DB/Migrations/Profile/004-CharacterCopperToGenericCopper.lua")
DoWoWFile("DB/Migrations/Profile/005-AllowAndDenyFilters.lua")
DoWoWFile("Internal/Filter.lua")
DoWoWFile("Internal/FilterFactoryRegistry.lua")
DoWoWFile("Internal/FilterFactory/Character.lua")
DoWoWFile("Internal/FilterFactory/Combined.lua")
DoWoWFile("Internal/FilterFactory/CharacterPattern.lua")
DoWoWFile("Internal/FilterFactory/Copper.lua")
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
