---@class ns
local _, ns = ...

local copperColumns = {
	copper = "gold",
	personalCopper = "personalGold",
	guildBankCopper = "guildBankGold",
}

---@param fields string[]
---@param dataTable DataTable
local function CopperToGold(fields, dataTable)
	local moneyColumnIndexes = {}
	for i, field in next, fields do
		if copperColumns[field] then
			moneyColumnIndexes[i] = true
			fields[i] = copperColumns[field]
		end
	end

	for _, row in ipairs(dataTable) do
		for j in next, moneyColumnIndexes do
			if row[j] then
				row[j] = row[j] / 10000 -- COPPER_PER_GOLD
			end
		end
	end
end

if ns then
	if not ns.DataTableTransformers then ns.DataTableTransformers = {} end
	ns.DataTableTransformers.CopperToGold = CopperToGold
end
return CopperToGold
