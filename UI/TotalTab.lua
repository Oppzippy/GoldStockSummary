---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale(addonName)

---@class TotalTab : AceEvent-3.0
local TotalTab = {
	widgets = {},
}
AceEvent:Embed(TotalTab)

function TotalTab:Show()
	if self:IsVisible() then error("already shown") end

	local group = AceGUI:Create("InlineGroup")
	---@cast group AceGUIInlineGroup
	self.widgets.frame = group
	group:SetLayout("Table")
	group:SetUserData("table", {
		columns = {
			{
				width = 0.5,
				alignH = "RIGHT",
			},
			{
				width = 0.5,
				alignH = "LEFT",
			},
		},
		space = 5,
	})
	group:SetCallback("OnRelease", function()
		self:OnRelease()
	end)

	self:OnMoneyUpdated()

	return group
end

function TotalTab:OnRelease()
	if self.widgets.frame then
		self.widgets = {}
	end
end

function TotalTab:IsVisible()
	return self.widgets.frame ~= nil
end

function TotalTab:OnMoneyUpdated()
	if self:IsVisible() then
		-- TODO this logic should be moved out of the UI
		local db = ns.db.global
		local trackedMoney = ns.TrackedMoney.Create(db.characters, db.guilds)
		local total = 0
		local personalTotal = 0
		local guildBankTotal = 0
		for name, realm in trackedMoney:IterateCharacters() do
			local characterCopper = trackedMoney:GetCharacterCopper(name, realm)
			total = total + characterCopper.totalCopper
			personalTotal = personalTotal + characterCopper.personalCopper
			guildBankTotal = guildBankTotal + (characterCopper.guildCopper or 0)
		end
		self.widgets.frame:ReleaseChildren()
		self:AddCell(L.total_money, "RIGHT")
		self:AddCell(GetMoneyString(total, true), "LEFT")
		self:AddCell(L.total_personal_money, "RIGHT")
		self:AddCell(GetMoneyString(personalTotal, true), "LEFT")
		self:AddCell(L.total_guild_bank_money, "RIGHT")
		self:AddCell(GetMoneyString(guildBankTotal, true), "LEFT")
	end
end

---@param text string
---@param justifyH "LEFT"|"CENTER"|"RIGHT"
function TotalTab:AddCell(text, justifyH)
	local cell = AceGUI:Create("Label")
	---@cast cell AceGUILabel
	self.widgets.totalGold = cell
	cell:SetFullWidth(true)
	cell:SetFontObject(GameFontHighlightMedium)
	cell:SetText(text)
	cell:SetJustifyH(justifyH)

	self.widgets.frame:AddChild(cell)
end

TotalTab:RegisterMessage("GoldStockSummary_MoneyUpdated", "OnMoneyUpdated")
ns.TotalTab = TotalTab
