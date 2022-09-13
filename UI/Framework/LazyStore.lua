---@class ns
local ns = select(2, ...)

---@class LazyStore
---@field reducer Reducer
---@field state unknown
---@field getState fun(): unknown
---@field subscribers table<number, fun()>
---@field lastID number
---@field queuedUpdate? Ticker
local LazyStorePrototype = {}

---@param reducer Reducer
---@param getState fun(): unknown
---@return LazyStore
local function Create(reducer, getState)
	local store = setmetatable({
		reducer = reducer,
		getState = getState,
		subscribers = {},
		lastID = 0,
	}, { __index = LazyStorePrototype })

	return store
end

---@param func fun()
---@return fun()
function LazyStorePrototype:Subscribe(func)
	if not next(self.subscribers) then
		self.state = self.getState()
	end
	local id = self.lastID
	self.subscribers[id] = func
	self.lastID = self.lastID + 1
	return function()
		self.subscribers[id] = nil
	end
end

function LazyStorePrototype:Dispatch(action)
	if not next(self.subscribers) then return end

	self.state = self.reducer(self.state, action)
	-- Group together updates on the next frame
	if not self.queuedUpdate then
		self.queuedUpdate = C_Timer.NewTimer(0, function()
			self.queuedUpdate = nil
			for _, subscriber in self.subscribers do
				subscriber()
			end
		end)
	end
end

function LazyStorePrototype:GetState()
	return self.state
end

ns.LazyStore = {
	Create = Create,
}
