---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale(addonName)

---@class MainUI : AceEvent-3.0
local MainUI = {
	widgets = {},
}
AceEvent:Embed(MainUI)

---@param getTableData table<string, fun(): string[], table>
---@param db AceDBObject-3.0
function MainUI:Show(getTableData, db)
	if self:IsVisible() then return end
	local frame = AceGUI:Create("Frame")
	---@cast frame AceGUIFrame
	self.widgets.frame = frame

	-- This must be cleaned up later when frame is released
	GoldStockSummaryFrame = frame.frame
	self.uiSpecialFramesIndex = #UISpecialFrames + 1
	UISpecialFrames[self.uiSpecialFramesIndex] = "GoldStockSummaryFrame"

	frame:EnableResize(false)
	frame:SetTitle(L.gold_stock_summary)
	frame:SetLayout("Fill")
	frame:SetCallback("OnClose", function()
		self:Hide()
	end)
	frame:SetWidth(960)
	frame:SetHeight(500)

	local tabGroup = AceGUI:Create("TabGroup")
	---@cast tabGroup AceGUITabGroup
	tabGroup:SetLayout("Fill")

	tabGroup:SetCallback("OnGroupSelected", function(_, _, group)
		tabGroup:ReleaseChildren()
		if group == "reports" then
			local tab = ns.ReportsTab:Show(getTableData, db)
			tabGroup:AddChild(tab)
		elseif group == "filters" then
			ns.FiltersTab.characters = db.global.characters
			ns.FiltersTab.filters = db.profile.filters
			local filtersTab = ns.FiltersTab:Render()
			tabGroup:AddChild(filtersTab)
			tabGroup:DoLayout()
		end
	end)

	tabGroup:SetTabs({
		{
			text = L.reports,
			value = "reports",
		},
		{
			text = L.filters,
			value = "filters",
		},
	})
	tabGroup:SelectTab("reports")

	frame:AddChild(tabGroup)
end

function MainUI:Hide()
	if self.widgets.frame then
		self.widgets.frame:Release()
		self.widgets = {}
		table.remove(UISpecialFrames, self.uiSpecialFramesIndex)
		GoldStockSummaryFrame = nil
	end
end

function MainUI:IsVisible()
	return self.widgets.frame ~= nil
end

ns.MainUI = MainUI
