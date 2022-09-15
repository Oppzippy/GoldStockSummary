---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)
---@class ns.Components
local components = ns.Components

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale(addonName)

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
			return bIsDefaultFilter
		end
		return a.name < b.name
	end)
	return filters, reverseIndex
end

---@type Component
components.FilterSelection = {
	---@param container AceGUIContainer
	create = function(container, props)
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
			props.setFilter(filters[filterID])
		end)
		container:AddChild(dropdown)

		return {
			watch = { ns.FilterStore },
		}, {
			dropdown = dropdown,
			setFilter = props.setFilter,
		}
	end,
	update = function(props)
		local filters, reverseIndex = getSortedFilters()
		local list = {}
		local order = {}
		for i, filter in ipairs(filters) do
			local filterID = reverseIndex[filter]
			list[filterID] = filter.name
			order[i] = filterID
		end

		props.dropdown:SetList(list, order)
		if not props.dropdown:GetValue() then
			local filtersByID = ns.FilterStore:GetState()
			props.dropdown:SetValue(order[1])
			props.setFilter(filtersByID[order[1]])
		end
	end,
}
