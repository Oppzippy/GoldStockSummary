---@class ns
local ns = select(2, ...)

---@param db GlobalDB
ns.migrations.global[1] = function(db)
	if not db or not db.characters then return end

	local newCharacters = {}
	for nameAndRealm, info in next, db.characters do
		local name, realm = nameAndRealm:gmatch("([^-]+)-(.+)")()
		info.name = name
		info.realm = realm
		local normalizedRealm = realm:gsub("[ -]", "")
		newCharacters[string.format("%s-%s", name, normalizedRealm)] = info
	end
	db.characters = newCharacters
end
