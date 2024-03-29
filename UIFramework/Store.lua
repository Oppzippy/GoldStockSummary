---@class ns
local ns = select(2, ...)

---@class Store
---@field reducer Reducer
---@field state unknown
---@field subscribers table<number, fun()>
---@field dispatchSubscribers table<number, fun()>
---@field lastID number
---@field actionQueue table[]
local StorePrototype = {}

---@param reducer Reducer
---@param initialState unknown
---@return Store
local function Create(reducer, initialState)
	local store = setmetatable({
		reducer = reducer,
		state = initialState,
		subscribers = {},
		dispatchSubscribers = {},
		lastID = 0,
		actionQueue = {},
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

---@param func fun()
---@return fun()
function StorePrototype:SubscribeToDispatches(func)
	local id = self.lastID
	self.dispatchSubscribers[id] = func
	self.lastID = self.lastID + 1
	return function()
		self.dispatchSubscribers[id] = nil
	end
end

function StorePrototype:Dispatch(action)
	self.actionQueue[#self.actionQueue + 1] = action
	for _, subscriber in next, self.dispatchSubscribers do
		subscriber()
	end
end

function StorePrototype:Update()
	local numActions = #self.actionQueue
	for _, action in ipairs(self.actionQueue) do
		self.state = self.reducer(self.state, action)
	end
	self.actionQueue = {}

	if numActions > 0 then
		for _, subscriber in next, self.subscribers do
			subscriber()
		end
	end
end

function StorePrototype:GetState()
	return self.state
end

ns.Store = {
	Create = Create,
}
