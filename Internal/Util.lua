---@class ns
local _, ns = ...

local export = {}

function export.CloneTableShallow(t)
	local copy = {}
	for k, v in next, t do
		copy[k] = v
	end
	return copy
end

if ns then
	ns.Util = export
end
return export
