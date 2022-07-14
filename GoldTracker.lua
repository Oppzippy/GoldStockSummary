---@class ns
local _, ns = ...

local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local ScrollingTable = LibStub("ScrollingTable")

---@class GoldTrackerCore : AceConsole-3.0, AceEvent-3.0, AceAddon
local Core = AceAddon:NewAddon("GoldTracker", "AceConsole-3.0", "AceEvent-3.0")

function Core:OnInitialize()
	self.db = AceDB:New("GoldTrackerDB", ns.dbDefaults, true)
	ns.db = self.db

	self:RegisterChatCommand("goldtracker", "SlashCommand")
end

function Core:SlashCommand(args)
	self:GetGoldCSV()
end

function Core:GetGoldByRealmCSV()
	local realms = {}
	for player, copperSources in next, self.db.global.characterCopper do
		local totalCopper = 0
		for _, copper in next, copperSources do
			totalCopper = totalCopper + copper
		end
		local name, realm = strsplit("-", player)
		if not realms[realm] then
			realms[realm] = {}
		end
		realms[realm].copper = (realms[realm].copper or 0) + totalCopper
		if not realms[realm].newestUpdate or realms[realm].newestUpdate < self.db.global.characterLastUpdate[player] then
			realms[realm].newestUpdate = self.db.global.characterLastUpdate[player]
		end
		if not realms[realm].oldestUpdate or realms[realm].oldestUpdate > self.db.global.characterLastUpdate[player] then
			realms[realm].oldestUpdate = self.db.global.characterLastUpdate[player]
		end
	end

	local csv = {}
	for realm, info in next, realms do
		local newestUpdate, oldestUpdate
		if info.newestUpdate then
			newestUpdate = date("%Y-%m-%d %I:%M:%S %p", info.newestUpdate)
		end
		if info.oldestUpdate then
			oldestUpdate = date("%Y-%m-%d %I:%M:%S %p", info.oldestUpdate)
		end
		csv[#csv + 1] = string.format(
			"%s,%s,%s,%s",
			realm,
			info.copper / COPPER_PER_GOLD,
			newestUpdate or "",
			oldestUpdate or ""
		)
	end
	return table.concat(csv, "\n")
end

function Core:GetGoldCSV()
	local data = ns.GetGoldByCharacter(self.db.global.characterSnapshots)
	local t = self:DataToTable({ "realm", "name" }, data)

	local st = ScrollingTable:CreateST(self:ScrollingTableColumns({ "relam", "name" }))
	st:SetData(t, true)
end

function Core:DataToTable(columns, data)
	local csv = {}
	for i, entry in ipairs(data) do
		local row = {}
		for j, column in ipairs(columns) do
			row[j] = entry[column]
		end
		csv[i] = row
	end
	return csv
end

function Core:ScrollingTableColumns(columns)
	local headings = {}
	for i, column in ipairs(columns) do
		headings[i] = {
			name = column, -- TODO localize
			width = 50,
		}
	end
	return headings
end
