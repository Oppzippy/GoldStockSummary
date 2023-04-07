local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

DoWoWFile("Tests/Filter/CharacterBlacklistFilter.lua")
DoWoWFile("Tests/Filter/CharacterWhitelistFilter.lua")
DoWoWFile("Tests/Filter/CombinedFilter.lua")
DoWoWFile("Tests/Filter/PatternWhitelistFilter.lua")
DoWoWFile("Tests/Filter/PatternBlacklistFilter.lua")
DoWoWFile("Tests/MoneyTable/Factory/Characters.lua")
DoWoWFile("Tests/MoneyTable/Factory/Realms.lua")
DoWoWFile("Tests/MoneyTable/Factory/RealmsWithCombinedFactions.lua")
DoWoWFile("Tests/MoneyTable/Map.lua")
DoWoWFile("Tests/MoneyTable/MapFields.lua")
DoWoWFile("Tests/MoneyTable/ConvertTypes.lua")
DoWoWFile("Tests/DB/Migrations/Global/001-NormalizeRealmNames.lua")
DoWoWFile("Tests/DB/Migrations/Profile/001-MigrateFilters.lua")

os.exit(luaunit.LuaUnit.run())
