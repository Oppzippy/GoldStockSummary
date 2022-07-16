---@class ns
local _, ns = ...

local dateColumns = {
	lastUpdate = "lastUpdateRFC3339",
}

---@param fields string[]
---@param dataTable DataTable
local function TimestampToRFC3339(fields, dataTable)
	local dateColumnIndexes = {}
	for i, field in next, fields do
		if dateColumns[field] then
			dateColumnIndexes[i] = true
			fields[i] = dateColumns[field]
		end
	end

	for _, row in ipairs(dataTable) do
		for j in next, dateColumnIndexes do
			local value = row[j]
			if value then
				---@cast value integer
				local dateString = date("!%Y-%m-%dT%TZ", value)
				---@cast dateString string
				row[j] = dateString
			end
		end
	end
end

if ns then
	if not ns.DataTableTransformers then ns.DataTableTransformers = {} end
	ns.DataTableTransformers.TimestampToRFC3339 = TimestampToRFC3339
end
return TimestampToRFC3339
