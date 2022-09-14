---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

---@class ClipboardModule : AceConsole-3.0, AceEvent-3.0
local module = AceAddon:GetAddon(addonName):NewModule("Clipboard", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterMessage("GoldStockSummary_CopyText", "OnCopyText")
end

function module:OnCopyText(_, text)
	self:Copy(text)
end

function module:Copy(text)
	local editBox = GoldStockSummaryClipboardFrame.scrollFrame.editBox
	---@cast editBox EditBox
	if text:find("\n", nil, true) then
		editBox:SetMultiLine(true)
	else
		editBox:SetMultiLine(false)
	end

	editBox:SetText(text)
	editBox:HighlightText(0, #text)
	GoldStockSummaryClipboardFrame:Show()
end

function module:Hide()
	GoldStockSummaryClipboardFrame:Hide()
end
