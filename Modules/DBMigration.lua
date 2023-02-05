---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

---@class DBMigrationModule : AceModule
local module = AceAddon:GetAddon(addonName):NewModule("DBMigration")

function module:OnInitialize()
	self:Migrate("global")
end

function module:Migrate(dbType)
	local numMigrations = #ns.migrations[dbType]
	local currentMigrationIndex = ns.db[dbType]._migration or 0

	for i = currentMigrationIndex + 1, numMigrations do
		local migration = ns.migrations[dbType][i]
		migration(ns.db[dbType])
		ns.db[dbType]._migration = i
	end
end
