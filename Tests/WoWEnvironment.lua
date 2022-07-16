function GetLocale()
	return "enUS"
end

strmatch = string.match

require("Libs.LibStub.LibStub")
-- Can't use require for this since it converts periods to path separators
dofile("Libs/AceLocale-3.0/AceLocale-3.0.lua")

require("Locales.enUS")
