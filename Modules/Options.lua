---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local L = AceLocale:GetLocale(addonName)

---@class OptionsModule : AceModule, AceEvent-3.0
local module = AceAddon:GetAddon(addonName):NewModule("Options", "AceEvent-3.0")
---@type AceConfigOptionsTable
module.optionsTable = {
	type = "group",
	handler = module,
	childGroups = "tab",
	order = 1,
	args = {
		general = {
			type = "group",
			name = L.general,
			order = 1,
			args = {
				showMinimapIcon = {
					type = "toggle",
					name = L.show_minimap_icon,
					get = "IsMinimapIconShown",
					set = "SetMinimapIconShown",
					order = 1,
				},
				debugMode = {
					type = "toggle",
					name = L.debug_mode,
					get = "GetOption",
					set = "SetOption",
				},
			},
		},
		export = {
			type = "group",
			name = L.export,
			order = 2,
			args = {
				csv = {
					type = "group",
					name = L.csv,
					order = 1,
					inline = true,
					args = {
						csvFloorGold = {
							type = "toggle",
							get = "GetOption",
							set = "SetOption",
							name = L.round_gold_down,
							desc = L.round_gold_down_desc,
						},
					},
				},
			},
		},
		guildBlacklist = {
			type = "group",
			name = L.guild_blacklist,
			order = 3,
			get = "IsGuildBlacklisted",
			set = "SetGuildBlacklisted",
			args = {},
		},
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

	local profiles = AceDBOptions:GetOptionsTable(self.db)
	AceConfig:RegisterOptionsTable(addonName .. "_Profiles", profiles)
	AceConfigDialog:AddToBlizOptions(addonName .. "_Profiles", L.profiles, L.gold_stock_summary)


	self:UpdateGuilds()
	self:RegisterMessage("GoldStockSummary_GuildAdded", "OnGuildsChanged")
end

function module:OnGuildsChanged()
	self:UpdateGuilds()
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

function module:UpdateGuilds()
	---@type table<string, AceConfigOptionsTable>
	local args = {
		help = {
			type = "description",
			fontSize = "medium",
			name = L.guild_blacklist_help,
			order = 0,
		},
		header = {
			type = "header",
			name = L.guilds,
			order = 1,
		},
	}
	local order = 2
	for guildName in next, self.db.global.guilds do
		args[guildName] = {
			type = "toggle",
			name = guildName,
			order = order,
			width = "full",
		}
		order = order + 1
	end
	self.optionsTable.args.guildBlacklist.args = args
end

function module:IsGuildBlacklisted(info)
	local guild = self.db.global.guilds[info[#info]]
	return guild and guild.isBlacklisted
end

function module:SetGuildBlacklisted(info, val)
	local guild = self.db.global.guilds[info[#info]]
	guild.isBlacklisted = val or nil
end

function module:GetOption(info)
	return self.db.profile[info[#info]]
end

function module:SetOption(info, val)
	self.db.profile[info[#info]] = val
end
