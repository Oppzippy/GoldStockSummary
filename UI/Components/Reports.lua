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

function componentPrototype:Initialize(container)
	container:SetLayout("Flow")

	local selectedFilterStore = ns.ValueStore.Create(nil)
	local selectedTabStore = ns.ValueStore.Create(nil)

	local filterSelection = ns.UIFramework:CreateComponent(
		ns.Components.FilterSelection,
		{
			setFilter = function(filter)
				selectedFilterStore:Dispatch(filter)
			end,
		}
	)
	container:AddChild(filterSelection:GetWidget())

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

	self.tabGroup = tabGroup
	self.selectedTabStore = selectedTabStore
	self.selectedFilterStore = selectedFilterStore

	return {
		stores = { selectedFilterStore, selectedTabStore, ns.MoneyStore },
	}
end

function componentPrototype:Update()
	self.tabGroup:ReleaseChildren()
	local selectedTab = self.selectedTabStore:GetState()
	---@type Filter?
	local filter = self.selectedFilterStore:GetState()

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
		component = ns.UIFramework:CreateComponent(ns.Components.Characters, props)
	elseif selectedTab == "realms" then
		component = ns.UIFramework:CreateComponent(ns.Components.Realms, props)
	elseif selectedTab == "total" then
		component = ns.UIFramework:CreateComponent(ns.Components.Total, props)
	end

	if component then
		local widget = component:GetWidget()
		self.tabGroup:AddChild(widget)
		widget:DoLayout()
	end
end

components.Reports = componentPrototype
