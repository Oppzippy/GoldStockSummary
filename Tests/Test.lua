local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

DoWoWFile("Tests/TrackedMoneyToMoneyTable.lua")

os.exit(luaunit.LuaUnit.run())
