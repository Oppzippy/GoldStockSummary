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
	widgets = {},
}
AceEvent:Embed(ReportsTab)

---@param getTableData table<string, fun(): string[], table>
---@return AceGUIContainer
function ReportsTab:Show(getTableData)
	local frame = AceGUI:Create("SimpleGroup")
	---@cast frame AceGUISimpleGroup
	self.widgets.frame = frame
	frame:SetCallback("OnRelease", function()
		self.widgets = {}
	end)
	frame:SetLayout("Table")
	frame:SetUserData("table", {
		columns = {
			{
				width = 100,
			},
			{
				weight = 1,
			},
		},
	})
	frame:SetFullWidth(true)
	frame:SetFullHeight(true)
	local filterLabel = AceGUI:Create("Label")
	---@cast filterLabel AceGUILabel
	filterLabel:SetText(L.filter)
	frame:AddChild(filterLabel)

	local filterSelection = AceGUI:Create("Dropdown")
	---@cast filterSelection AceGUIDropdown
	filterSelection:SetFullWidth(true)
	self.widgets.filterSelection = filterSelection
	frame:AddChild(filterSelection)

	-- The tab group needs its parent to have layout Fill
	local tabGroupParent = AceGUI:Create("SimpleGroup")
	---@cast tabGroupParent AceGUISimpleGroup
	tabGroupParent:SetUserData("cell", {
		colspan = 2,
	})
	tabGroupParent:SetLayout("Fill")
	tabGroupParent:SetFullWidth(true)

	local tabGroup = AceGUI:Create("TabGroup")
	---@cast tabGroup AceGUITabGroup
	tabGroup:SetLayout("Fill")

	tabGroup:SetCallback("OnGroupSelected", function(_, _, group)
		self.currentTab = group
		tabGroup:ReleaseChildren()
		---@type AceGUIContainer?
		local tab
		if group == "characters" then
			tab = ns.CharactersTab:Show(getTableData[group])
		elseif group == "realms" then
			tab = ns.RealmsTab:Show(getTableData[group])
		elseif group == "total" then
			tab = ns.TotalTab:Show()
			-- The layout doesn't seem to get updated automatically when the size is changed to match the parent
		end

		if tab then
			tabGroup:AddChild(tab)
			tab:DoLayout()
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
	tabGroupParent:AddChild(tabGroup)
	frame:AddChild(tabGroupParent)

	return frame
end

function ReportsTab:UpdateFilters(_, _, filters)
	local options = {}
	for id, filter in next, filters do
		options[id] = filter.name
	end
	self.widgets.filterSelection:SetList(options)
end

AceEvent:RegisterMessage("GoldStockSummary_FiltersChanged")

ns.ReportsTab = ReportsTab
