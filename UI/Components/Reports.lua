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

		local selectedFilterStore = ns.ValueStore.Create(nil)
		local selectedTabStore = ns.ValueStore.Create(nil)

		local filterSelection = ns.ComponentFactory.Create(
			ns.Components.FilterSelection,
			{
				setFilter = function(filter)
					selectedFilterStore:Dispatch(filter)
				end,
			}
		)
		container:AddChild(filterSelection.widget)

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
			selectedTabStore:Dispatch(group)
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

		return {
			watch = { selectedFilterStore, selectedTabStore, ns.MoneyStore },
		}, {
			tabGroup = tabGroup,
			selectedTabStore = selectedTabStore,
			selectedFilterStore = selectedFilterStore,
		}
	end,
	update = function(state)
		state.tabGroup:ReleaseChildren()
		local selectedTab = state.selectedTabStore:GetState()
		---@type Filter?
		local filter = state.selectedFilterStore:GetState()

		local moneyState = ns.MoneyStore:GetState()
		local characters, guilds = moneyState.characters, moneyState.guilds

		if filter then
			-- TODO add a wrapper around this so we don't have the first return
			local _
			_, characters = filter:Filter(characters)
		end

		local props = {
			characters = characters,
			guilds = guilds,
		}

		---@type Component
		local component
		if selectedTab == "characters" then
			component = ns.ComponentFactory.Create(ns.Components.Characters, props)
		elseif selectedTab == "realms" then
			component = ns.ComponentFactory.Create(ns.Components.Realms, props)
		elseif selectedTab == "total" then
			component = ns.ComponentFactory.Create(ns.Components.Total, props)
		end

		if component then
			state.tabGroup:AddChild(component.widget)
			component.widget:DoLayout()
		end
	end,
}
