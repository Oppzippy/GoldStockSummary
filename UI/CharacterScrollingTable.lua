---@class ns
local _, ns = ...

local CallbackHandler = LibStub("CallbackHandler-1.0")
local AceGUI = LibStub("AceGUI-3.0")

local CharacterScrollingTable = {
	frames = {},
}
CharacterScrollingTable.callbacks = CallbackHandler:New(CharacterScrollingTable)

---@param columns string[]
---@param data CharacterMoneyTable
function CharacterScrollingTable:Show(columns, data)
	if self:IsVisible() then return end
	local frame = AceGUI:Create("Frame")
	---@cast frame AceGUIFrame
	self.frames.frame = frame
	frame:EnableResize(false)
	frame:SetTitle("Character Gold")
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function()
		self:Hide()
	end)

	-- The headings of the scrolling table overlap the top of the frame without a spacer
	local spacer = AceGUI:Create("SimpleGroup")
	---@cast spacer AceGUISimpleGroup
	spacer:SetHeight(10)
	frame:AddChild(spacer)

	self.frames.scrollingTable = AceGUI:Create("GoldTracker-ScrollingTable")
	-- self.frames.scrollingTable:SetFullWidth(true)
	self.frames.scrollingTable:SetDisplayCols(columns)
	self.frames.scrollingTable:SetData(data)
	self.frames.scrollingTable:EnableSelection(true)
	frame:AddChild(self.frames.scrollingTable)

	local search = AceGUI:Create("EditBox")
	---@cast search AceGUIEditBox
	search:SetLabel("Search")
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		self.frames.scrollingTable:SetFilter(function(_, row)
			local query = text:lower()
			local name, realm = row[1], row[2]
			local nameAndRealm = string.format("%s-%s", name, realm)
			return nameAndRealm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	frame:AddChild(search)

	local delete = AceGUI:Create("Button")
	---@cast delete AceGUIButton
	delete:SetText("Delete Selected Character")
	delete:SetDisabled(true)
	delete:SetCallback("OnClick", function()
		local selectedIndex = self.frames.scrollingTable:GetSelection()
		if not selectedIndex then return end

		local row = self.frames.scrollingTable:GetRow(selectedIndex)
		local name, realm = row[1], row[2]
		local nameAndRealm = string.format("%s-%s", name, realm)
		self.callbacks:Fire("OnDelete", nameAndRealm)
	end)
	frame:AddChild(delete)

	self.frames.scrollingTable:SetCallback("OnSelectionChanged", function()
		delete:SetDisabled(self.frames.scrollingTable:GetSelection() == nil)
	end)

	frame:SetWidth(self.frames.scrollingTable.frame:GetWidth() + frame.frame.RightEdge:GetWidth())
end

function CharacterScrollingTable:Hide()
	if self.frames.frame then
		self.frames.frame:Release()
		self.frames = {}
	end
end

function CharacterScrollingTable:IsVisible()
	return self.frames.frame ~= nil
end

---@param data CharacterMoneyTable
function CharacterScrollingTable:SetData(data)
	self.frames.scrollingTable:SetData(data)
end

ns.CharacterScrollingTable = CharacterScrollingTable
