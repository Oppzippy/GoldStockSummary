---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)
---@class ns.Components
local components = ns.Components

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale(addonName)

---@type Component
components.Reports = {
	create = function(container)
		container:SetLayout("Flow")

		local filterGroup = AceGUI:Create("SimpleGroup")
		---@cast filterGroup AceGUISimpleGroup
		filterGroup:SetFullWidth(true)
		filterGroup:SetLayout("Table")
		filterGroup:SetUserData("table", {
			columns = {
				{
					width = 100,
				},
				{
					weight = 1,
				},
			},
		})
		local filterLabel = AceGUI:Create("Label")
		---@cast filterLabel AceGUILabel
		filterLabel:SetText(L.filter)
		filterGroup:AddChild(filterLabel)

		local filterSelection = AceGUI:Create("Dropdown")
		---@cast filterSelection AceGUIDropdown
		filterGroup:AddChild(filterSelection)

		container:AddChild(filterGroup)

		-- The tab group needs its parent to have layout Fill
		local tabGroupParent = AceGUI:Create("SimpleGroup")
		---@cast tabGroupParent AceGUISimpleGroup
		tabGroupParent:SetLayout("Fill")
		tabGroupParent:SetFullWidth(true)
		tabGroupParent:SetFullHeight(true)

		local tabGroup = AceGUI:Create("TabGroup")
		---@cast tabGroup AceGUITabGroup
		tabGroup:SetLayout("Fill")

		tabGroup:SetCallback("OnGroupSelected", function(_, _, group)
			tabGroup:ReleaseChildren()
			---@type AceGUIContainer?
			local tab
			if group == "characters" then
				local component = ns.ComponentFactory.Create(ns.Components.Characters)
				tab = component.widget
			elseif group == "realms" then
				local component = ns.ComponentFactory.Create(ns.Components.Realms)
				tab = component.widget
			elseif group == "total" then
				local component = ns.ComponentFactory.Create(ns.Components.Total)
				tab = component.widget
			end

			if tab then
				tabGroup:AddChild(tab)
				tab:DoLayout()
			end
		end)

		tabGroup:SetTabs({
			{
				text = L.characters,
				value = "characters",
			},
			{
				text = L.realms,
				value = "realms",
			},
			{
				text = L.total,
				value = "total",
			},
		})
		tabGroup:SelectTab("characters")
		tabGroupParent:AddChild(tabGroup)
		container:AddChild(tabGroupParent)
	end,
	-- update = function() end,
}
