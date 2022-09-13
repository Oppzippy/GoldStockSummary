---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale(addonName)

---@class ReportsTab : AceEvent-3.0
local ReportsTab = {
	currentTab = "characters",
}
AceEvent:Embed(ReportsTab)

---@param getTableData table<string, fun(): string[], table>
---@param db AceDBObject-3.0
---@return AceGUIContainer
function ReportsTab:Show(getTableData, db)
	local frame = AceGUI:Create("SimpleGroup")
	---@cast frame AceGUISimpleGroup

	frame:SetLayout("Fill")

	local tabGroup = AceGUI:Create("TabGroup")
	---@cast tabGroup AceGUITabGroup
	tabGroup:SetLayout("Fill")

	tabGroup:SetCallback("OnGroupSelected", function(_, _, group)
		self.currentTab = group
		tabGroup:ReleaseChildren()
		if group == "characters" then
			local charactersTab = ns.CharactersTab:Show(getTableData[group])
			tabGroup:AddChild(charactersTab)
		elseif group == "realms" then
			local realmsTab = ns.RealmsTab:Show(getTableData[group])
			tabGroup:AddChild(realmsTab)
		elseif group == "total" then
			local totalTab = ns.TotalTab:Show()
			tabGroup:AddChild(totalTab)
			-- The layout doesn't seem to get updated automatically when the size is changed to match the parent
			totalTab:DoLayout()
		end
	end)

	tabGroup:SetTabs({
		{
			text = L.characters,
			value = "characters",
		},
		{
			text = L.realms,
			value = "realms",
		},
		{
			text = L.total,
			value = "total",
		},
	})
	tabGroup:SelectTab(self.currentTab)

	frame:AddChild(tabGroup)

	return frame
end

ns.ReportsTab = ReportsTab
