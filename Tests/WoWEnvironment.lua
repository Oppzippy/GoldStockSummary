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

-- Locales
DoWoWFile("Locales/enUS.lua")

--- Internal
DoWoWFile("Internal/DataConversion/DataTableConversion.lua")
DoWoWFile("Internal/DataConversion/MoneyTableConversion.lua")
DoWoWFile("Internal/DataConversion/ScrollingTableConversion.lua")
DoWoWFile("Internal/MoneyTable/MoneyTable.lua")
DoWoWFile("Internal/MoneyTable/MoneyTableCollection.lua")
DoWoWFile("Internal/MoneyTable/MoneyTableEntry.lua")
DoWoWFile("Internal/ColumnLocalizer.lua")
DoWoWFile("Internal/Util.lua")
