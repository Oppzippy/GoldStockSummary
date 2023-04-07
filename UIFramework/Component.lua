---@meta
---@class Component.InitializationOptions
---@field stores? Store[]

---@class Component
---@field watch? Store[]
local Component = {}

---@param container AceGUIContainer
---@param props? table
---@return Component.InitializationOptions options, unknown passthrough
function Component:Initialize(container, props)
end

function Component:Update()
end

function Component:OnDestroy()
end

---@return AceGUIContainer
function Component:GetWidget()
end
