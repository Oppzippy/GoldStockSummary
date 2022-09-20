---@type string
local addonName = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

L.gold_stock_summary = "Gold Stock Summary"
L.export = "Export"
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
L.general = "General"
L.guild_blacklist = "Guild Blacklist"
L.guild_blacklist_help = "Checked guilds are not counted towards your gold on any character even if you are the guild master."
L.blacklist = "Blacklist"
L.guilds = "Guilds"
L.total = "Total"
L.total_money = "Total Money:"
L.total_personal_money = "Total Personal Money:"
L.total_guild_bank_money = "Total Guild Bank Money:"

L.filters = "Filters"
L.name = "Name"
L.type = "Type"
L.whitelist = "Whitelist"
L.combined_filter = "Combined Filter"
L.list_type = "List Type"
L.character_list = "Character List"
L.pattern = "Pattern"
L.realm = "Realm"
L.list = "List"
L.click_to_remove = "Click to Remove"
L.settings = "Settings"
L.new_filter = "New Filter"
L.filter_settings = "Filter Settings"
L.filter_already_exists = "A filter named \"%s\" already exists. Filter names must be unique."
L.add_character = "Add Character"
L.delete = "Delete"
L.delete_are_you_sure = "Are you sure you want to delete the filter: \"%s\"?"
L.reports = "Reports"
L.filter = "Filter"
L.allow_all = "Allow All"
L.deny_all = "Deny All"
L.filter_x = "Filter %d"
L.add_filter = "Add Filter"
L.remove_filter = "Remove Filter"
L.new_filter_help = [[
Filters can be used to display and export a subset of your characters. The following filter types are available:
Whitelist: Set characters to be shown.
Blacklist: Set characters to be hidden.
Combined: Combine whitelist and blacklist filters.

Whitelist and Blacklist filters have a List Type option. Character List lets you provide a list of characters that the filter should match. Pattern lets you provide a string, and the filter will match any character names containing that string.

When filters are combined, they will be evaluated from first to last. As soon as a character matches a filter, it will be either allowed or denied and no more filters will be evaluated for that character. For example, you have character A and character B with a blacklist containing B whiltelist containing both A and B, you would get the following results:
Whitelist first: Both A and B will be allowed.
Blacklist first: B will be denied, A will be allowed.

If you want a whitelist to match all characters on a realm, an easy way to do that is with the pattern list type. Set the pattern to "-Your Realm Name". To match multiple realms, create multiple whitelists and then combine them with a combined filter.
]]
L.profiles = "Profiles"

L["columns/name"] = "Name"
L["columns/realm"] = "Realm"
L["columns/totalMoney"] = "Total Money"
L["columns/personalMoney"] = "Personal Money"
L["columns/guildBankMoney"] = "Guild Bank Money"
L["columns/lastUpdate"] = "Last Update"
L["columns/faction"] = "Faction"
