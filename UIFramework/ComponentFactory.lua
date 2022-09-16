---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

---@class ComponentFactory
local ComponentFactory = {}

local queuedUpdateOrder = {}
local queuedUpdateArgs = {}

local function updateComponents()
	local updateOrder, updateArgs = queuedUpdateOrder, queuedUpdateArgs
	queuedUpdateOrder, queuedUpdateArgs = {}, {}

	for _, component in ipairs(updateOrder) do
		component.update(unpack(updateArgs[component]))
	end
end

local function queueUpdate(component, args)
	if queuedUpdateArgs[component] then return end
	if not queuedUpdateOrder[1] then
		C_Timer.After(0, updateComponents)
	end
	queuedUpdateOrder[#queuedUpdateOrder + 1] = component
	queuedUpdateArgs[component] = args
end

---@param component Component
---@param props? table
---@return {widget: AceGUISimpleGroup}
function ComponentFactory.Create(component, props)
	local container = AceGUI:Create("SimpleGroup")
	---@cast container AceGUISimpleGroup
	local options, passthrough = component.create(container, props)
	local updateArgs = { passthrough }

	if options and options.watch then
		local unsubscribeFunctions = {}
		for i, store in ipairs(options.watch) do
			unsubscribeFunctions[i] = store:Subscribe(function()
				queueUpdate(component, updateArgs)
			end)
		end

		container:SetCallback("OnRelease", function()
			for _, unsubscribe in ipairs(unsubscribeFunctions) do
				unsubscribe()
			end
		end)
	end

	if component.update then
		queueUpdate(component, updateArgs)
	end

	return {
		widget = container,
	}
end

ns.ComponentFactory = ComponentFactory
