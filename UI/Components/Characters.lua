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

local tableFields = { "realm", "faction", "name", "totalMoney", "personalMoney", "guildBankMoney", "lastUpdate" }

local componentPrototype = {}

local persistentSortColumn, persistentSortDirection

function componentPrototype:Initialize(container, props)
	container:PauseLayout()
	container:SetLayout("Flow")

	-- The headings of the scrolling table overlap the top of the frame without a spacer
	local spacer = AceGUI:Create("SimpleGroup")
	---@cast spacer AceGUISimpleGroup
	spacer:SetHeight(10)
	container:AddChild(spacer)

	local scrollingTable = AceGUI:Create("GoldStockSummary-ScrollingTable")
	scrollingTable:SetFullWidth(true)
	scrollingTable:EnableSelection(true)
	scrollingTable:SetCallback("OnSortingChanged", function(_, _, column, direction)
		persistentSortColumn = column
		persistentSortDirection = direction
	end)
	container:AddChild(scrollingTable)

	local search = AceGUI:Create("EditBox")
	---@cast search AceGUIEditBox
	search:SetLabel("Search")
	search:DisableButton(true)
	search:SetCallback("OnTextChanged", function(_, _, text)
		scrollingTable:SetFilter(function(_, row)
			local query = text:lower()
			local name, realm = row.cols[3].value, row.cols[1].value
			local nameAndRealm = string.format("%s-%s", name, realm)
			return nameAndRealm:lower():find(query, nil, true)
		end)
	end)
	search:SetFullWidth(true)
	container:AddChild(search)

	local delete = AceGUI:Create("Button")
	---@cast delete AceGUIButton
	delete:SetText(L.delete_selected_character)
	delete:SetDisabled(true)
	delete:SetCallback("OnClick", function()
		local selectedIndex = scrollingTable:GetSelection()
		if not selectedIndex then return end

		local row = scrollingTable:GetRow(selectedIndex)
		AceEvent.SendMessage(container, "GoldStockSummary_DeleteCharacter", row.id)
	end)
	container:AddChild(delete)

	local exportCSV = AceGUI:Create("Button")
	---@cast exportCSV AceGUIButton
	exportCSV:SetText(L.export_csv)
	exportCSV:SetCallback("OnClick", function()
		local results = self.resultsStore:GetState()
		AceEvent.SendMessage(container, "GoldStockSummary_ExportCharacters", "csv", {
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
		AceEvent.SendMessage(container, "GoldStockSummary_ExportCharacters", "json", {
			characters = results.characters,
			guilds = results.guilds,
		})
	end)
	container:AddChild(exportJSON)

	scrollingTable:SetCallback("OnSelectionChanged", function()
		delete:SetDisabled(scrollingTable:GetSelection() == nil)
	end)

	container:ResumeLayout()
	container:DoLayout()

	self.scrollingTable = scrollingTable
	self.resultsStore = props.resultsStore

	return {
		stores = { props.resultsStore },
	}
end

function componentPrototype:Update()
	local results = self.resultsStore:GetState()

	local trackedMoney = ns.TrackedMoney.Create(results.characters, results.guilds)
	local moneyTable = ns.MoneyTable.Factory.Characters(trackedMoney)
	local columns, rows = ns.MoneyTable.To.ScrollingTable(tableFields, moneyTable)

	local ids = moneyTable:ToRows({ "id" })
	for i, row in ipairs(rows) do
		row.id = ids[i][1]
	end

	self.scrollingTable:SetDisplayCols(columns)
	self.scrollingTable:SetData(rows)

	if persistentSortColumn then
		self.scrollingTable:SetSort(persistentSortColumn, persistentSortDirection)
	end
end

components.Characters = componentPrototype
