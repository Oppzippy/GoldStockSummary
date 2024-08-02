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
L.guild_blacklist_help =
"Checked guilds are not counted towards your gold on any character even if you are the guild master."
L.blacklist = "Blacklist"
L.guilds = "Guilds"
L.total = "Total"
L.total_money = "Total Money:"
L.total_personal_money = "Total Personal Money:"
L.total_guild_bank_money = "Total Guild Bank Money:"
L.total_account_bank_money = "Total Account Bank Money:"

L.filters = "Filters"
L.name = "Name"
L.type = "Type"
L.character = "Character"
L.character_pattern = "Character Pattern"
L.combined_filter = "Combined Filter"
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
Character: Match against a list of characters.
Character Pattern: Match character names containing a lua string pattern.
Money: Match characters based on personal/guild/total money.
Combined: Chain filters together.

The following actions can be applied to matches of a filter:
Allow Matches: Anything that matches the filter is allowed. If this filter is not a child of a Combined Filter, anything that does not match is denied.
Deny Matches: Anything that matches the filter is denied. If this filter is not a child of a Combined Filter, anything that does not match is allowed.
Allow All Except Matches: Anything that does not match the filter is allowed. If this filter is not a child of a Combined Filter, anything that does match is denied.
Deny All Except Matches: Anything that does not match the filter is denied. If this filter is not a child of a Combined Filter, anything that does match is allowed.

Note that for combined filters with a deny action, characters allowed by child filters will be denied.

When filters are combined, they will be evaluated from first to last. As soon as a character matches a filter, it will be either allowed or denied according to the filter, and no more filters will be evaluated for that character. For example, if you have character A and character B, and a combined filter containing a Deny Matches filter matching B and an Allow Matches filter containing both A and B, you would get the following results:
Deny Matches filter first: B will be denied, A will be allowed.
Allow Matches filter first: Both A and B will be allowed.

If you want an allow filter to match all characters on a realm, an easy way to do that is with the Character Pattern filter type. Set the pattern to "-Your Realm Name". To match multiple realms, create multiple Character Pattern filters and then combine them with a combined filter.
]]
L.profiles = "Profiles"
L.combine_factions = "Combine Factions"
L.comparison = "Comparison"
L.gold = "Gold"
L.silver = "Silver"
L.copper = "Copper"
L.sign = "Sign"
L.character_money = "Character Money"
L.character = "Character"
L.guild = "Guild"
L.money = "Money"
L.action = "Action"
L.allow_matches = "Allow Matches"
L.deny_matches = "Deny Matches"
L.allow_all_except_matches = "Allow All Except Matches"
L.deny_all_except_matches = "Deny All Except Matches"
L.csv = "CSV"
L.round_gold_down = "Round Gold Down"
L.round_gold_down_desc = "Removes the fractional part by flooring the number."

L["columns/name"] = "Name"
L["columns/realm"] = "Realm"
L["columns/totalMoney"] = "Total Money"
L["columns/personalMoney"] = "Personal Money"
L["columns/guildBankMoney"] = "Guild Bank Money"
L["columns/lastUpdate"] = "Last Update"
L["columns/faction"] = "Faction"
