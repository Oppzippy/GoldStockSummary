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

	local selectedTabStore = ns.ValueStore.Create(nil)

	local initialMoneyState = ns.MoneyStore:GetState()
	self.filteredResultsStore = ns.ValueStore.Create({
		characters = initialMoneyState.characters,
		guilds = initialMoneyState.guilds,
	})
	self.unsubscribeMoneyStore = ns.MoneyStore:Subscribe(function()
		self:UpdateFilteredResultsStore()
	end)

	local filterSelection = ns.UIFramework:CreateComponent(
		ns.Components.FilterSelection,
		{
			setFilter = function(filter)
				self.filter = filter
				self:UpdateFilteredResultsStore()
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

	return {
		stores = { selectedTabStore },
	}
end

function componentPrototype:OnDestroy()
	self.unsubscribeMoneyStore()
end

function componentPrototype:UpdateFilteredResultsStore()
	local moneyState = ns.MoneyStore:GetState()
	local characters, guilds = moneyState.characters, moneyState.guilds

	if self.filter then
		-- TODO add a wrapper around this so we don't have the first return
		local _
		_, characters = self.filter:Filter(characters)
		self.filteredResultsStore:Dispatch({
			characters = characters,
			guilds = guilds,
		})
	end
end

function componentPrototype:Update()
	self.tabGroup:ReleaseChildren()
	local selectedTab = self.selectedTabStore:GetState()

	local props = {
		resultsStore = self.filteredResultsStore,
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
