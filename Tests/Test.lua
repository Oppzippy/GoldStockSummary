local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

DoWoWFile("Tests/Filter/CharacterBlacklistFilter.lua")
DoWoWFile("Tests/Filter/CharacterWhitelistFilter.lua")
DoWoWFile("Tests/Filter/CombinedFilter.lua")
DoWoWFile("Tests/Filter/PatternWhitelistFilter.lua")
DoWoWFile("Tests/Filter/PatternBlacklistFilter.lua")
DoWoWFile("Tests/MoneyTable/Factory/Characters.lua")
DoWoWFile("Tests/MoneyTable/Map.lua")
DoWoWFile("Tests/MoneyTable/MapFields.lua")
DoWoWFile("Tests/MoneyTable/ConvertTypes.lua")

os.exit(luaunit.LuaUnit.run())
