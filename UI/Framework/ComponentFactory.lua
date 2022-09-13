---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")

---@class ComponentFactory
local ComponentFactory = {}

---@param component Component
---@return AceGUISimpleGroup
function ComponentFactory.Create(component)
	local container = AceGUI:Create("SimpleGroup")
	---@cast container AceGUISimpleGroup
	local returns = { component.create(container) }

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

	component.update(unpack(returns))

	return container
end

ns.ComponentFactory = ComponentFactory
