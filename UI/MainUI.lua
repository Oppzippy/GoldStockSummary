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
	})
	tabGroup:SelectTab("characters")

	frame:AddChild(tabGroup)
end

function MainUI:Hide()
	if self.widgets.frame then
		self.widgets.frame:Release()
		self.widgets = {}
	end
end

function MainUI:IsVisible()
	return self.widgets.frame ~= nil
end

ns.MainUI = MainUI
