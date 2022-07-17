local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

DoWoWFile("Tests/MoneyTable/FromTrackedMoney.lua")
DoWoWFile("Tests/MoneyTable/Map.lua")
DoWoWFile("Tests/MoneyTable/MapFields.lua")
DoWoWFile("Tests/MoneyTable/ConvertTypes.lua")

os.exit(luaunit.LuaUnit.run())
