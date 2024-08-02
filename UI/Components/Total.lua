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
	container:SetLayout("List")
	container:SetFullWidth(true)
	container:SetFullHeight(true)

	local grid = AceGUI:Create("SimpleGroup")
	---@cast grid AceGUISimpleGroup
	grid:SetFullWidth(true)
	grid:SetLayout("Table")
	grid:SetUserData("table", {
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
	-- Account bank gold for retail only
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		cells[#cells + 1] = self:CreateCell("RIGHT", L.total_account_bank_money)
		cells[#cells + 1] = self:CreateCell("LEFT")
	end

	grid:PauseLayout()
	for _, cell in ipairs(cells) do
		grid:AddChild(cell)
	end
	grid:ResumeLayout()
	grid:DoLayout()

	container:AddChild(grid)

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		local optionsGroup = AceGUI:Create("InlineGroup")
		---@cast optionsGroup AceGUIInlineGroup
		optionsGroup:SetFullWidth(true)
		optionsGroup:SetLayout("Flow")

		-- When using filters, including the account bank may or may not make sense, so
		-- an option is provided to include/exclude it from the total
		local includeAccountBankStore = ns.ValueStore.Create(ns.db.profile.includeAccountBankInTotal)
		local accountBankCheckBox = AceGUI:Create("CheckBox")
		---@cast accountBankCheckBox AceGUICheckBox
		accountBankCheckBox:SetValue(includeAccountBankStore:GetState())
		accountBankCheckBox:SetLabel(L.include_account_bank_in_total)
		accountBankCheckBox:SetFullWidth(true)
		accountBankCheckBox:SetCallback("OnValueChanged", function(_, _, isChecked)
			self:SetIncludeAccountBankInTotal(isChecked)
		end)
		optionsGroup:AddChild(accountBankCheckBox)

		container:AddChild(optionsGroup)
		self.includeAccountBankStore = includeAccountBankStore
	end

	self.container = container
	self.cells = cells
	self.resultsStore = props.resultsStore

	return {
		-- includeAccountBankStore can be nil, but since it's the last element in the table,
		-- that will not create any holes, so it's fine.
		stores = { self.resultsStore, ns.MoneyStore, self.includeAccountBankStore },
	}
end

---@param isIncluded boolean
function componentPrototype:SetIncludeAccountBankInTotal(isIncluded)
	self.includeAccountBankStore:Dispatch(isIncluded)
	ns.db.profile.includeAccountBankInTotal = isIncluded
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
	local moneyState = ns.MoneyStore:GetState()
	local results = self.resultsStore:GetState()
	local trackedMoney = ns.TrackedMoney.Create(results.characters, results.guilds)
	local total = 0
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and self.includeAccountBankStore:GetState() and moneyState.accountBank then
		total = total + moneyState.accountBank.copper
	end
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
	-- Account bank gold for retail only
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		self.cells[8]:SetText(GetMoneyString(moneyState.accountBank and moneyState.accountBank.copper or 0))
	end

	self.container:DoLayout()
end

components.Total = componentPrototype
