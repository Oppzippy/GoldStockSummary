---@class ns
local ns = select(2, ...)

local reducer = function(_, newValue)
	return newValue
end

---@param initialState unknown
---@return Store
local function Create(initialState)
	return ns.Store.Create(reducer, initialState)
end

ns.ValueStore = {
	Create = Create,
}
