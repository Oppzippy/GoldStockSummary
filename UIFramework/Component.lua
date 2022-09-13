---@class Component
---@field watch? Store[]
local Component = {}

---@param container AceGUIContainer
---@param props? table
---@return ...unknown
function Component.create(container, props) end

---@param ... unknown
function Component.update(...) end
