---@class ns
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GoldTracker")

---@class CharactersTab : AceEvent-3.0
local CharacterScrollingTable = {
	widgets = {},
}
AceEvent:Embed(CharacterScrollingTable)

---@param columns string[]
---@param data table
function CharacterScrollingTable:Show(columns, data)
	if self:IsVisible() then return end
	local frame = AceGUI:Create("Frame")
	---@cast frame AceGUIFrame
	self.widgets.frame = frame
	frame:PauseLayout()
	frame:EnableResize(false)
	frame:SetTitle(L.character_gold)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function()
		self:Hide()
	end)

	-- The headings of the scrolling table overlap the top of the frame without a spacer
	local spacer = AceGUI:Create("SimpleGroup")
	---@cast spacer AceGUISimpleGroup
	spacer:SetHeight(10)
	frame:AddChild(spacer)

	self.widgets.scrollingTable = AceGUI:Create("GoldTracker-ScrollingTable")
	self.widgets.scrollingTable:SetDisplayCols(columns)
	self.widgets.scrollingTable:SetData(data)
	self.widgets.scrollingTable:EnableSelection(true)
	frame:AddChild(self.widgets.scrollingTable)

	local search = AceGUI:Create("EditBox")
	---@cast search AceGUIEditBox
	search:SetLabel("Search")
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		self.widgets.scrollingTable:SetFilter(function(_, row)
			local query = text:lower()
			local name, realm = row.cols[1].value, row.cols[2].value
			local nameAndRealm = string.format("%s-%s", name, realm)
			return nameAndRealm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	frame:AddChild(search)

	local delete = AceGUI:Create("Button")
	---@cast delete AceGUIButton
	delete:SetText(L.delete_selected_character)
	delete:SetDisabled(true)
	delete:SetCallback("OnClick", function()
		local selectedIndex = self.widgets.scrollingTable:GetSelection()
		if not selectedIndex then return end

		local row = self.widgets.scrollingTable:GetRow(selectedIndex)
		-- TODO attach the data to the row somehow rather than depending on column order
		local name, realm = row.cols[3].value, row.cols[1].value
		local nameAndRealm = string.format("%s-%s", name, realm)
		self:SendMessage("GoldTracker_DeleteCharacter", nameAndRealm)
	end)
	frame:AddChild(delete)

	local exportCSV = AceGUI:Create("Button")
	---@cast exportCSV AceGUIButton
	exportCSV:SetText(L.export_csv)
	exportCSV:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportCharacters", "csv")
	end)
	frame:AddChild(exportCSV)

	local exportJSON = AceGUI:Create("Button")
	---@cast exportJSON AceGUIButton
	exportJSON:SetText(L.export_json)
	exportJSON:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportCharacters", "json")
	end)
	frame:AddChild(exportJSON)

	local exportContainer = AceGUI:Create("SimpleGroup")
	---@cast exportContainer AceGUISimpleGroup
	self.widgets.exportContainer = exportContainer
	exportContainer:SetFullWidth(true)
	exportContainer:SetFullHeight(true)
	frame:AddChild(exportContainer)

	self.widgets.scrollingTable:SetCallback("OnSelectionChanged", function()
		delete:SetDisabled(self.widgets.scrollingTable:GetSelection() == nil)
	end)

	frame:SetWidth(self.widgets.scrollingTable.frame:GetWidth() + frame.frame.RightEdge:GetWidth())
	frame:ResumeLayout()
	frame:DoLayout()
end

function CharacterScrollingTable:Hide()
	if self.widgets.frame then
		self.widgets.frame:Release()
		self.widgets = {}
	end
end

function CharacterScrollingTable:IsVisible()
	return self.widgets.frame ~= nil
end

function CharacterScrollingTable:SetData(data)
	self.widgets.scrollingTable:SetData(data)
end

---@param text string
function CharacterScrollingTable:OnSetExportCharactersOutput(_, text)
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

CharacterScrollingTable:RegisterMessage("GoldTracker_SetExportCharactersOutput", "OnSetExportCharactersOutput")
ns.CharacterScrollingTable = CharacterScrollingTable
