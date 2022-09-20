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

local function getSortedFilters()
	local filtersByID = ns.FilterStore:GetState()
	---@type Filter[]
	local filters = {}
	---@type table<Filter, unknown>
	local reverseIndex = {}

	for id, filter in next, filtersByID do
		filters[#filters + 1] = filter
		reverseIndex[filter] = id
	end
	table.sort(filters, function(a, b)
		local aID, bID = reverseIndex[a], reverseIndex[b]
		local aIsDefaultFilter = type(aID) == "string"
		local bIsDefaultFilter = type(bID) == "string"

		if aIsDefaultFilter ~= bIsDefaultFilter then
			return aIsDefaultFilter
		end
		return a.name < b.name
	end)
	return filters, reverseIndex
end

function componentPrototype:Initialize(container, props)
	container:SetFullWidth(true)
	container:SetLayout("Table")
	container:SetUserData("table", {
		columns = {
			{
				width = 100,
			},
			{
				weight = 1,
			},
		},
	})
	local label = AceGUI:Create("Label")
	---@cast label AceGUILabel
	label:SetText(L.filter)
	container:AddChild(label)

	local dropdown = AceGUI:Create("Dropdown")
	---@cast dropdown AceGUIDropdown
	dropdown:SetCallback("OnValueChanged", function(_, _, filterID)
		local filters = ns.FilterStore:GetState()
		props.setFilter(filters[filterID], filterID)
	end)
	container:AddChild(dropdown)

	self.dropdown = dropdown
	self.setFilter = props.setFilter
	self.initialSelection = props.initialSelection

	return {
		stores = { ns.FilterStore },
	}
end

function componentPrototype:Update()
	local filters, reverseIndex = getSortedFilters()
	local list = {}
	local order = {}
	for i, filter in ipairs(filters) do
		local filterID = reverseIndex[filter]
		list[filterID] = filter.name
		order[i] = filterID
	end

	self.dropdown:SetList(list, order)
	if not self.dropdown:GetValue() then
		local filtersByID = ns.FilterStore:GetState()
		local selection = order[1]
		if self.initialSelection and filtersByID[self.initialSelection] then
			-- Make sure the selected filter isn't deleted
			selection = self.initialSelection
			self.initialSelection = nil
		end

		self.dropdown:SetValue(selection)
		self.setFilter(filtersByID[selection])
	end
end

components.FilterSelection = componentPrototype
