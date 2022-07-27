---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local L = AceLocale:GetLocale(addonName)

---@class OptionsModule : AceEvent-3.0
local module = AceAddon:GetAddon(addonName):NewModule("Options", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

module.optionsTable = {
	type = "group",
	handler = module,
	order = 1,
	args = {
		showMinimapIcon = {
			type = "toggle",
			name = L.show_minimap_icon,
			get = "IsMinimapIconShown",
			set = "SetMinimapIconShown",
			order = 1,
		}
	},
}

function module:OnInitialize()
	self.db = ns.db

	local dataObject = LDB:NewDataObject(addonName, {
		type = "launcher",
		text = L.gold_stock_summary,
		icon = 133784, -- Interface/Icons/INV_Misc_Coin_01
		OnClick = function()
			self:SendMessage("GoldStockSummary_ToggleUI")
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L.gold_stock_summary)
		end,
	})
	LDBIcon:Register(addonName, dataObject, self.db.profile.minimapIcon)

	AceConfig:RegisterOptionsTable(addonName, self.optionsTable)
	AceConfigDialog:AddToBlizOptions(addonName, L.gold_stock_summary)
end

function module:IsMinimapIconShown()
	return not self.db.profile.minimapIcon.hide
end

function module:SetMinimapIconShown(_, val)
	self.db.profile.minimapIcon.hide = not val
	if val then
		LDBIcon:Show(addonName)
	else
		LDBIcon:Hide(addonName)
	end
end
