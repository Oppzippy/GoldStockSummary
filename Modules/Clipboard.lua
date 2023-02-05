---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

---@class ClipboardModule : AceModule, AceEvent-3.0
local module = AceAddon:GetAddon(addonName):NewModule("Clipboard", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterMessage("GoldStockSummary_CopyText", "OnCopyText")
end

function module:OnCopyText(_, text)
	self:Copy(text)
end

function module:Copy(text)
	local frame, editBox

	---@cast editBox EditBox
	if text:find("\n", nil, true) then
		---@type Frame
		frame = GoldStockSummaryMultiLineClipboardFrame
		---@type EditBox
		editBox = GoldStockSummaryMultiLineClipboardFrame.scrollFrame.editBox
	else
		---@type Frame
		frame = GoldStockSummarySingleLineClipboardFrame
		---@type EditBox
		editBox = GoldStockSummarySingleLineClipboardFrame.editBox
	end

	editBox:SetText(text)
	editBox:HighlightText(0, #text)
	editBox:SetCursorPosition(0)
	frame:Show()
end
