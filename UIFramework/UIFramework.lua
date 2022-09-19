---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

---@class UIFramework
local UIFramework = {
	---@type table<Store, table<Component, boolean>>
	storesToComponents = {},
	---@type table<Store,boolean>
	globalStores = {},
	---@type table<Store, fun()>
	storeUnsubscribeFunctions = {},
	---@type table<Store, boolean>
	storeUpdateQueue = {},
	nextFrameUpdate = false,
}

---@param prototype Component
---@param props? table
function UIFramework:CreateComponent(prototype, props)
	local container = AceGUI:Create("SimpleGroup")
	---@type Component
	local component = setmetatable({
		GetWidget = function()
			return container
		end,
	}, { __index = prototype })

	---@cast container AceGUISimpleGroup
	local options = component:Initialize(container, props)

	if options.stores then
		for _, store in ipairs(options.stores) do
			self:SubscribeComponentToStore(component, store)
		end

		container:SetCallback("OnRelease", function()
			for _, store in ipairs(options.stores) do
				self:UnsubscribeComponentFromStore(component, store)
			end
			if component.OnDestroy then
				component:OnDestroy()
			end
		end)
	end

	if component.Update then
		component:Update()
	end

	return component
end

function UIFramework:RegisterGlobalStore(store)
	self:SubscribeToStore(store)
	self.globalStores[store] = true
end

---@param component Component
---@param store Store
function UIFramework:SubscribeComponentToStore(component, store)
	self:SubscribeToStore(store)
	self.storesToComponents[store][component] = true
end

function UIFramework:SubscribeToStore(store)
	if not self.storesToComponents[store] then
		self.storesToComponents[store] = {}
		self.storeUnsubscribeFunctions[store] = store:Subscribe(function()
			self:TriggerUpdateForStore(store)
		end)
		self:TriggerUpdateForStore(store)
	end
end

function UIFramework:UnregisterGlobalStore(store)
	self.globalStores[store] = nil
	self:UnsubscribeFromStoreIfEmpty(store)
end

---@param component Component
---@param store Store
function UIFramework:UnsubscribeComponentFromStore(component, store)
	self.storesToComponents[store][component] = nil
	self:UnsubscribeFromStoreIfEmpty(store)
end

function UIFramework:UnsubscribeFromStoreIfEmpty(store)
	if not self.globalStores[store] and not next(self.storesToComponents[store]) then
		self.storeUnsubscribeFunctions[store]()
		self.storeUnsubscribeFunctions[store] = nil
		self.storesToComponents[store] = nil
	end
end

---@param store Store
function UIFramework:TriggerUpdateForStore(store)
	self.storeUpdateQueue[store] = true
	self:TriggerNextFrameUpdate()
end

function UIFramework:TriggerNextFrameUpdate()
	if not self.nextFrameUpdate then
		self.nextFrameUpdate = true
		C_Timer.After(0, function()
			self.nextFrameUpdate = false
			self:Update()
		end)
	end
end

function UIFramework:Update()
	self:UpdateStores()
	self:UpdateComponents()
end

function UIFramework:UpdateStores()
	for store in next, self.storesToComponents do
		store:Update()
	end
end

function UIFramework:UpdateComponents()
	local queue = self.storeUpdateQueue
	self.storeUpdateQueue = {}
	local num = 0
	for store in next, queue do
		for component in next, self.storesToComponents[store] do
			num = num + 1
			component:Update()
		end
	end
end

ns.UIFramework = UIFramework
