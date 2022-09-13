---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

---@class ComponentFactory
local ComponentFactory = {}

---@param component Component
---@param props? table
---@return {widget: AceGUISimpleGroup}
function ComponentFactory.Create(component, props)
	local container = AceGUI:Create("SimpleGroup")
	---@cast container AceGUISimpleGroup
	local returns = { component.create(container, props) }

	if component.watch then
		local unsubscribeFunctions = {}
		for i, store in ipairs(component.watch) do
			unsubscribeFunctions[i] = store:Subscribe(function()
				component.update(unpack(returns))
			end)
		end

		container:SetCallback("OnRelease", function()
			for _, unsubscribe in ipairs(unsubscribeFunctions) do
				unsubscribe()
			end
		end)
	end

	if component.update then
		component.update(unpack(returns))
	end

	return {
		widget = container,
	}
end

ns.ComponentFactory = ComponentFactory
