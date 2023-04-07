---@class ns
local ns = select(2, ...)

ns.MoneyUtil = {}


---@param totalCopper integer
---@return integer
function ns.MoneyUtil.GetGold(totalCopper)
	return math.floor(totalCopper / COPPER_PER_GOLD)
end

---@param totalCopper integer
---@return integer
function ns.MoneyUtil.GetSilver(totalCopper)
	return math.floor((totalCopper % COPPER_PER_GOLD) / COPPER_PER_SILVER)
end

---@param totalCopper integer
---@return integer
function ns.MoneyUtil.GetCopper(totalCopper)
	return totalCopper % COPPER_PER_SILVER
end

---@param totalCopper integer
---@param gold integer
---@return integer
function ns.MoneyUtil.SetGoldUnit(totalCopper, gold)
	gold = gold * COPPER_PER_GOLD
	local silver = ns.MoneyUtil.GetSilver(totalCopper) * COPPER_PER_SILVER
	local copper = ns.MoneyUtil.GetCopper(totalCopper)

	return gold + silver + copper
end

---@param totalCopper integer
---@param silver integer
---@return integer
function ns.MoneyUtil.SetSilverUnit(totalCopper, silver)
	local gold = ns.MoneyUtil.GetGold(totalCopper) * COPPER_PER_GOLD
	silver = silver * COPPER_PER_SILVER
	local copper = ns.MoneyUtil.GetCopper(totalCopper)

	return gold + silver + copper
end

---@param totalCopper integer
---@param copper integer
---@return integer
function ns.MoneyUtil.SetCopperUnit(totalCopper, copper)
	local gold = ns.MoneyUtil.GetGold(totalCopper) * COPPER_PER_GOLD
	local silver = ns.MoneyUtil.GetSilver(totalCopper) * COPPER_PER_SILVER

	return gold + silver + copper
end
