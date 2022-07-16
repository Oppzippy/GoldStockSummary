local luaunit = require("luaunit")

require("Tests.WoWEnvironment")

require("Tests.TrackedMoneyToMoneyTable")

os.exit(luaunit.LuaUnit.run())
