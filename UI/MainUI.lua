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
function MainUI:Show(getTableData)
	if self:IsVisible() then return end
	local frame = AceGUI:Create("Frame")
	---@cast frame AceGUIFrame
	self.widgets.frame = frame

	-- This must be cleaned up later when frame is released
	GoldStockSummaryFrame = frame.frame
	self.uiSpecialFramesIndex = #UISpecialFrames + 1
	UISpecialFrames[#UISpecialFrames + 1] = "GoldStockSummaryFrame"

	frame:EnableResize(false)
	frame:SetTitle(L.gold_stock_summary)
	frame:SetLayout("Fill")
	frame:SetCallback("OnClose", function()
		self:Hide()
	end)

	local tabGroup = AceGUI:Create("TabGroup")
	---@cast tabGroup AceGUITabGroup
	tabGroup:SetLayout("Fill")

	tabGroup:SetCallback("OnGroupSelected", function(_, _, group)
		tabGroup:ReleaseChildren()
		if group == "characters" then
			local charactersTab = ns.CharactersTab:Show(getTableData[group])
			frame:SetWidth(charactersTab.frame:GetWidth() + frame.frame.RightEdge:GetWidth() + 20)
			tabGroup:AddChild(charactersTab)
		elseif group == "realms" then
			local realmsTab = ns.RealmsTab:Show(getTableData[group])
			frame:SetWidth(realmsTab.frame:GetWidth() + frame.frame.RightEdge:GetWidth() + 20)
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
	tabGroup:SelectTab("characters")

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
