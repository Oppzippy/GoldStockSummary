---@type string, ns
local addonName, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local L = AceLocale:GetLocale("GoldTracker")

---@class Config : AceAddon, AceEvent-3.0
local Config = AceAddon:GetAddon("GoldTracker"):NewModule("Config", "AceEvent-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

Config.optionsTable = {
	type = "group",
	handler = Config,
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

function Config:OnInitialize()
	self.db = ns.db

	local dataObject = LDB:NewDataObject(addonName, {
		type = "launcher",
		text = L.goldtracker,
		icon = 133784, -- Interface/Icons/INV_Misc_Coin_01
		OnClick = function()
			self:SendMessage("GoldTracker_ToggleUI")
		end,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(L.goldtracker)
		end,
	})
	LDBIcon:Register(addonName, dataObject, self.db.profile.minimapIcon)

	AceConfig:RegisterOptionsTable(addonName, self.optionsTable)
	AceConfigDialog:AddToBlizOptions(addonName, L.goldtracker)
end

function Config:IsMinimapIconShown()
	return not self.db.profile.minimapIcon.hide
end

function Config:SetMinimapIconShown(_, val)
	self.db.profile.minimapIcon.hide = not val
	if val then
		LDBIcon:Show(addonName)
	else
		LDBIcon:Hide(addonName)
	end
end
