function GetLocale()
	return "enUS"
end

strmatch = string.match

local namespace = {}
function DoWoWFile(path)
	loadfile(path)(nil, namespace)
end

--Libraries
DoWoWFile("Libs/LibStub/LibStub.lua")
DoWoWFile("Libs/AceLocale-3.0/AceLocale-3.0.lua")
DoWoWFile("Libs/json.lua/json.lua")

-- Locales
DoWoWFile("Locales/enUS.lua")

--- Internal
DoWoWFile("Internal/MoneyTable/Namespace.lua")
DoWoWFile("Internal/MoneyTable/From/FromTrackedMoney.lua")
DoWoWFile("Internal/MoneyTable/To/ToCSV.lua")
DoWoWFile("Internal/MoneyTable/To/ToJSON.lua")
DoWoWFile("Internal/MoneyTable/To/ToScrollingTable.lua")
DoWoWFile("Internal/MoneyTable/MoneyTable.lua")
DoWoWFile("Internal/Util.lua")
