---@class ns
local ns = select(2, ...)

---@param db GlobalDB
ns.migrations.global[1] = function(db)
	local newCharacters = {}
	for nameAndRealm, info in next, db.characters do
		local name, realm = strsplit("-", nameAndRealm)
		info.name = name
		info.realm = realm
		local normalizedRealm = realm:gsub("[ -]", "")
		newCharacters[string.format("%s-%s", name, normalizedRealm)] = info
	end
	db.characters = newCharacters
end
