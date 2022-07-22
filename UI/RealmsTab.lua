---@class ns
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GoldTracker")

---@class RealmsTab : AceEvent-3.0
local RealmsTab = {
	widgets = {},
}
AceEvent:Embed(RealmsTab)

---@param getTableData fun(): string[], table
function RealmsTab:Show(getTableData)
	if self:IsVisible() then error("already shown") end
	local columns, data = getTableData()
	self.getTableData = getTableData

	local group = AceGUI:Create("SimpleGroup")
	---@cast group AceGUISimpleGroup
	self.widgets.frame = group
	group:PauseLayout()
	group:SetLayout("Flow")
	group:SetCallback("OnRelease", function()
		self:OnRelease()
	end)

	-- The headings of the scrolling table overlap the top of the frame without a spacer
	local spacer = AceGUI:Create("SimpleGroup")
	---@cast spacer AceGUISimpleGroup
	spacer:SetHeight(10)
	group:AddChild(spacer)

	self.widgets.scrollingTable = AceGUI:Create("GoldTracker-ScrollingTable")
	self.widgets.scrollingTable:SetDisplayCols(columns)
	self.widgets.scrollingTable:SetData(data)
	self.widgets.scrollingTable:EnableSelection(true)
	group:AddChild(self.widgets.scrollingTable)

	local search = AceGUI:Create("EditBox")
	---@cast search AceGUIEditBox
	search:SetLabel("Search")
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		self.widgets.scrollingTable:SetFilter(function(_, row)
			local query = text:lower()
			local realm = row.cols[1].value
			return realm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	group:AddChild(search)

	local exportCSV = AceGUI:Create("Button")
	---@cast exportCSV AceGUIButton
	exportCSV:SetText(L.export_csv)
	exportCSV:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportRealms", "csv")
	end)
	group:AddChild(exportCSV)

	local exportJSON = AceGUI:Create("Button")
	---@cast exportJSON AceGUIButton
	exportJSON:SetText(L.export_json)
	exportJSON:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportRealms", "json")
	end)
	group:AddChild(exportJSON)

	local exportContainer = AceGUI:Create("SimpleGroup")
	---@cast exportContainer AceGUISimpleGroup
	self.widgets.exportContainer = exportContainer
	exportContainer:SetFullWidth(true)
	exportContainer:SetFullHeight(true)
	group:AddChild(exportContainer)

	group:SetWidth(self.widgets.scrollingTable.frame:GetWidth())
	group:ResumeLayout()
	group:DoLayout()

	return group
end

function RealmsTab:OnRelease()
	if self.widgets.frame then
		self.widgets = {}
	end
end

function RealmsTab:IsVisible()
	return self.widgets.frame ~= nil
end

---@param text string
function RealmsTab:OnSetExportRealmsOutput(_, text)
	self.widgets.exportContainer:ReleaseChildren()

	local editBox
	---@cast editBox AceGUIEditBox
	if text:find("\n", nil, true) then
		self.widgets.exportContainer:SetLayout("Fill")
		editBox = AceGUI:Create("MultiLineEditBox")
	else
		self.widgets.exportContainer:SetLayout("List")
		editBox = AceGUI:Create("EditBox")
		editBox:SetFullWidth(true)
	end
	editBox:DisableButton(true)
	editBox:SetLabel("Export")
	editBox:SetText(text)
	editBox:SetFocus()
	editBox:HighlightText(0, #text)
	self.widgets.exportContainer:AddChild(editBox)
end

function RealmsTab:OnMoneyUpdated()
	if self:IsVisible() then
		local columns, rows = self.getTableData()
		self.widgets.scrollingTable:SetDisplayCols(columns)
		self.widgets.scrollingTable:SetData(rows)
	end
end

RealmsTab:RegisterMessage("GoldTracker_SetExportRealmsOutput", "OnSetExportRealmsOutput")
RealmsTab:RegisterMessage("GoldTracker_MoneyUpdated", "OnMoneyUpdated")
ns.RealmsTab = RealmsTab
