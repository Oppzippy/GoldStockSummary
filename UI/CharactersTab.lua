---@class ns
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale("GoldTracker")

---@class CharactersTab : AceEvent-3.0
local CharactersTab = {
	widgets = {},
}
AceEvent:Embed(CharactersTab)

---@param columns string[]
---@param data table
function CharactersTab:Show(columns, data)
	if self:IsVisible() then return end
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
			local name, realm = row.cols[1].value, row.cols[2].value
			local nameAndRealm = string.format("%s-%s", name, realm)
			return nameAndRealm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	group:AddChild(search)

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
	group:AddChild(delete)

	local exportCSV = AceGUI:Create("Button")
	---@cast exportCSV AceGUIButton
	exportCSV:SetText(L.export_csv)
	exportCSV:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportCharacters", "csv")
	end)
	group:AddChild(exportCSV)

	local exportJSON = AceGUI:Create("Button")
	---@cast exportJSON AceGUIButton
	exportJSON:SetText(L.export_json)
	exportJSON:SetCallback("OnClick", function()
		self:SendMessage("GoldTracker_ExportCharacters", "json")
	end)
	group:AddChild(exportJSON)

	local exportContainer = AceGUI:Create("SimpleGroup")
	---@cast exportContainer AceGUISimpleGroup
	self.widgets.exportContainer = exportContainer
	exportContainer:SetFullWidth(true)
	exportContainer:SetFullHeight(true)
	group:AddChild(exportContainer)

	self.widgets.scrollingTable:SetCallback("OnSelectionChanged", function()
		delete:SetDisabled(self.widgets.scrollingTable:GetSelection() == nil)
	end)

	group:SetWidth(self.widgets.scrollingTable.frame:GetWidth())
	group:ResumeLayout()
	group:DoLayout()

	return group
end

function CharactersTab:OnRelease()
	if self.widgets.frame then
		self.widgets = {}
	end
end

function CharactersTab:IsVisible()
	return self.widgets.frame ~= nil
end

function CharactersTab:SetData(data)
	self.widgets.scrollingTable:SetData(data)
end

---@param text string
function CharactersTab:OnSetExportCharactersOutput(_, text)
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

CharactersTab:RegisterMessage("GoldTracker_SetExportCharactersOutput", "OnSetExportCharactersOutput")
ns.CharacterScrollingTable = CharactersTab
