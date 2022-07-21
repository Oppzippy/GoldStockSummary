---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")

---@class SlashCommandModule : AceConsole-3.0, AceEvent-3.0
local module = AceAddon:GetAddon("GoldTracker"):NewModule("SlashCommand", "AceConsole-3.0", "AceEvent-3.0")

function module:OnInitialize()
	self:RegisterChatCommand("goldtracker", "SlashCommand")
end

function module:SlashCommand(args)
	self:SendMessage("GoldTracker_ToggleUI")
end
