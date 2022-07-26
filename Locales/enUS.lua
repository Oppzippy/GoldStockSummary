---@type string
local addonName = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

L.gold_stock_summary = "Gold Stock Summary"
L.export_csv = "Export CSV"
L.export_json = "Export JSON"
L.delete_selected_character = "Delete Selected Character"
L.deleted_item = "Deleted %s"
L.alliance = "Alliance"
L.horde = "Horde"
L.neutral = "Neutral"
L.show_minimap_icon = "Show Minimap Icon"
L.characters = "Characters"
L.realms = "Realms"

L["columns/name"] = "Name"
L["columns/realm"] = "Realm"
L["columns/totalMoney"] = "Total Money"
L["columns/personalMoney"] = "Personal Money"
L["columns/guildBankMoney"] = "Guild Bank Money"
L["columns/lastUpdate"] = "Last Update"
L["columns/faction"] = "Faction"
