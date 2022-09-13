---@class ns
local ns = select(2, ...)

---@class Store
---@field reducer Reducer
---@field state unknown
---@field subscribers table<number, fun()>
---@field lastID number
---@field queuedUpdate? Ticker
local StorePrototype = {}

---@param reducer Reducer
---@param initialState unknown
---@return Store
local function Create(reducer, initialState)
	local store = setmetatable({
		reducer = reducer,
		state = initialState,
		subscribers = {},
		lastID = 0,
	}, { __index = StorePrototype })

	return store
end

---@param func fun()
---@return fun()
function StorePrototype:Subscribe(func)
	local id = self.lastID
	self.subscribers[id] = func
	self.lastID = self.lastID + 1
	return function()
		self.subscribers[id] = nil
	end
end

function StorePrototype:Dispatch(action)
	self.state = self.reducer(self.state, action)
	-- Group together updates on the next frame
	if not self.queuedUpdate then
		self.queuedUpdate = C_Timer.NewTimer(0, function()
			self.queuedUpdate = nil
			for _, subscriber in next, self.subscribers do
				subscriber()
			end
		end)
	end
end

function StorePrototype:GetState()
	return self.state
end

ns.Store = {
	Create = Create,
}
