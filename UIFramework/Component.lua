---@class Component
---@field watch? Store[]
local Component = {}

---@param container AceGUIContainer
---@param props? table
---@return table options, unknown passthrough
function Component.create(container, props) end

---@param passthrough unknown
function Component.update(passthrough) end
