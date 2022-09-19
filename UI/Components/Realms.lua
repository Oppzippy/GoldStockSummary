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

local tableFields = { "realm", "faction", "totalMoney", "personalMoney", "guildBankMoney" }

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
		stores = { ns.MoneyStore },
	}
end

function componentPrototype:Update()
	local results = self.resultsStore:GetState()

	local moneyTable = ns.MoneyTable.Factory.Realms(ns.TrackedMoney.Create(results.characters, results.guilds))
	local columns, rows = ns.MoneyTable.To.ScrollingTable(tableFields, moneyTable)

	self.scrollingTable:SetDisplayCols(columns)
	self.scrollingTable:SetData(rows)
end

components.Realms = componentPrototype
