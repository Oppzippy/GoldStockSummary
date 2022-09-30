---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)
---@class ns.Components
local components = ns.Components

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceEvent = LibStub("AceEvent-3.0")

local L = AceLocale:GetLocale(addonName)

local componentPrototype = {}

function componentPrototype:Initialize(container, props)
	container:PauseLayout()
	container:SetLayout("Flow")

	-- The headings of the scrolling table overlap the top of the frame without a spacer
	local spacer = AceGUI:Create("SimpleGroup")
	---@cast spacer AceGUISimpleGroup
	spacer:SetHeight(10)
	container:AddChild(spacer)

	local scrollingTable = AceGUI:Create("GoldStockSummary-ScrollingTable")
	scrollingTable:EnableSelection(true)
	container:AddChild(scrollingTable)

	local search = AceGUI:Create("EditBox")
	---@cast search AceGUIEditBox
	search:SetLabel("Search")
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		scrollingTable:SetFilter(function(_, row)
			local query = text:lower()
			local realm = row.cols[1].value
			return realm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	container:AddChild(search)

	self.combineFactionsStore = ns.ValueStore.Create(false)
	local combineFactions = AceGUI:Create("CheckBox")
	---@cast combineFactions AceGUICheckBox
	combineFactions:SetLabel(L.combine_factions)
	combineFactions:SetCallback("OnValueChanged", function(_, _, value)
		self.combineFactionsStore:Dispatch(value)
	end)
	container:AddChild(combineFactions)

	local exportCSV = AceGUI:Create("Button")
	---@cast exportCSV AceGUIButton
	exportCSV:SetText(L.export_csv)
	exportCSV:SetCallback("OnClick", function()
		local results = self.resultsStore:GetState()
		AceEvent.SendMessage(container, "GoldStockSummary_ExportRealms", "csv", {
			characters = results.characters,
			guilds = results.guilds,
		})
	end)
	container:AddChild(exportCSV)

	local exportJSON = AceGUI:Create("Button")
	---@cast exportJSON AceGUIButton
	exportJSON:SetText(L.export_json)
	exportJSON:SetCallback("OnClick", function()
		local results = self.resultsStore:GetState()
		AceEvent.SendMessage(container, "GoldStockSummary_ExportRealms", "json", {
			characters = results.characters,
			guilds = results.guilds,
		})
	end)
	container:AddChild(exportJSON)

	container:ResumeLayout()
	container:DoLayout()

	self.scrollingTable = scrollingTable
	self.resultsStore = props.resultsStore

	return {
		stores = { self.resultsStore, self.combineFactionsStore },
	}
end

local tableFields = { "realm", "faction", "totalMoney", "personalMoney", "guildBankMoney" }
local tableFieldsWithCombinedFactions = { "realm", "totalMoney", "personalMoney", "guildBankMoney" }

function componentPrototype:Update()
	local results = self.resultsStore:GetState()
	local trackedMoney = ns.TrackedMoney.Create(results.characters, results.guilds)

	local columns, rows
	if self.combineFactionsStore:GetState() then
		local moneyTable = ns.MoneyTable.Factory.RealmsWithCombinedFactions(trackedMoney)
		columns, rows = ns.MoneyTable.To.ScrollingTable(tableFieldsWithCombinedFactions, moneyTable)
	else
		local moneyTable = ns.MoneyTable.Factory.Realms(trackedMoney)
		columns, rows = ns.MoneyTable.To.ScrollingTable(tableFields, moneyTable)
	end

	self.scrollingTable:SetDisplayCols(columns)
	self.scrollingTable:SetData(rows)
end

components.Realms = componentPrototype
