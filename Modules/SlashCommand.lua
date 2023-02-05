---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

---@class SlashCommandModule : AceModule, AceConsole-3.0, AceEvent-3.0
local module = AceAddon:GetAddon(addonName):NewModule("SlashCommand", "AceConsole-3.0", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterChatCommand("goldstocksummary", "SlashCommand")
	self:RegisterChatCommand("goldstock", "SlashCommand")
	self:RegisterChatCommand("gss", "SlashCommand")
end

function module:SlashCommand(args)
	self:SendMessage("GoldStockSummary_ToggleUI")
end
