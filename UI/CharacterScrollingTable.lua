---@class ns
local _, ns = ...

local AceGUI = LibStub("AceGUI-3.0")

local CharacterScrollingTable = {}

function CharacterScrollingTable:Show(columns, data)
	local frame = AceGUI:Create("Frame")
	frame:EnableResize(false)
	frame:SetTitle("Character Gold")
	frame:SetCallback("OnClose", function()
		self:Hide()
	end)

	self.scrollingTable = AceGUI:Create("GoldTracker-ScrollingTable")
	self.scrollingTable:SetDisplayCols(columns)
	self.scrollingTable:SetData(data, true)
	frame:AddChild(self.scrollingTable)
	frame:SetWidth(self.scrollingTable.frame:GetWidth() + frame.frame.RightEdge:GetWidth())
end

function CharacterScrollingTable:Hide()
	self.scrollingTable:Release()
end

ns.CharacterScrollingTable = CharacterScrollingTable
