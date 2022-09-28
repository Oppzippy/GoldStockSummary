---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)
---@class ns.Components
local components = ns.Components

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale(addonName)

local componentPrototype = {}

---@param container AceGUIContainer
---@param props table
function componentPrototype:Initialize(container, props)
	container:SetFullWidth(true)
	container:SetFullHeight(true)
	container:SetLayout("Table")
	container:SetUserData("table", {
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
	local cells = {
		self:CreateCell("RIGHT", L.total_money),
		self:CreateCell("LEFT"),
		self:CreateCell("RIGHT", L.total_personal_money),
		self:CreateCell("LEFT"),
		self:CreateCell("RIGHT", L.total_guild_bank_money),
		self:CreateCell("LEFT"),
	}
	container:PauseLayout()
	for _, cell in ipairs(cells) do
		container:AddChild(cell)
	end
	container:ResumeLayout()
	container:DoLayout()

	self.container = container
	self.cells = cells
	self.resultsStore = props.resultsStore

	return {
		stores = { self.resultsStore },
	}
end

---@param justifyH "LEFT"|"CENTER"|"RIGHT"
---@param text? string
function componentPrototype:CreateCell(justifyH, text)
	local cell = AceGUI:Create("Label")
	---@cast cell AceGUILabel
	cell:SetFontObject("GameFontHighlightMedium")
	cell:SetJustifyH(justifyH)
	if text then
		cell:SetText(text)
	end
	return cell
end

function componentPrototype:Update()
	local results = self.resultsStore:GetState()
	local trackedMoney = ns.TrackedMoney.Create(results.characters, results.guilds)
	local total = 0
	local personalTotal = 0
	local guildBankTotal = 0
	for nameAndRealm in trackedMoney:IterateCharacters() do
		local characterCopper = trackedMoney:GetCharacterCopper(nameAndRealm)
		total = total + characterCopper.totalCopper
		personalTotal = personalTotal + characterCopper.personalCopper
		guildBankTotal = guildBankTotal + (characterCopper.guildCopper or 0)
	end

	self.cells[2]:SetText(GetMoneyString(total, true))
	self.cells[4]:SetText(GetMoneyString(personalTotal, true))
	self.cells[6]:SetText(GetMoneyString(guildBankTotal, true))
	self.container:DoLayout()
end

components.Total = componentPrototype
