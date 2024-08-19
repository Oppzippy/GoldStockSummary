---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)

local AceAddon = LibStub("AceAddon-3.0")

---@class TrackerModule : AceModule, AceConsole-3.0, AceEvent-3.0, AceBucket-3.0
local module = AceAddon:GetAddon(addonName):NewModule("Tracker", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")

function module:OnInitialize()
	self.db = ns.db
end

function module:OnEnable()
	local nameAndRealm = self:GetCharacterNameAndRealm()
	local character = self:GetCharacter(nameAndRealm)
	---@diagnostic disable-next-line: assign-type-mismatch
	character.name = UnitName("player")
	character.realm = GetRealmName() -- Not normalized

	self:UpdateFaction()
	self:UpdateMoney()

	if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
		-- Used by vanilla classic
		self:RegisterEvent("GUILDBANKFRAME_OPENED", "UpdateGuildBankMoney")
	else
		-- Used by wotlk+ classic and retail
		self:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
	end
	self:RegisterEvent("PLAYER_MONEY", "UpdateMoney")
	self:RegisterEvent("GUILDBANK_UPDATE_MONEY", "UpdateGuildBankMoney")

	-- Account bank only exists on retail
	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		self:UpdateAccountBankMoney()
		self:RegisterEvent("ACCOUNT_MONEY", "UpdateAccountBankMoney")
	end

	-- These events can fire many times quickly. No point in repeatedly updating the same thing.
	self:RegisterBucketEvent("GUILD_RANKS_UPDATE", 1, "UpdateOwner")
	self:RegisterBucketEvent("PLAYER_GUILD_UPDATE", 1, "UpdateGuildAndOwner")

	C_Timer.After(0, function()
		-- GetGuildInfo will return nil until PLAYER_GUILD_UPDATE fires, but it's inconsistent and doesn't always fire when logging in.
		-- It seems to always be ready by the first frame, so we can just wait until then.
		-- TODO switch to https://wowpedia.fandom.com/wiki/FIRST_FRAME_RENDERED if classic supports it
		self.isFirstFrameRendered = true
		self:UpdateGuildAndOwner()
	end)
end

function module:IsInBrokenState()
	-- When events fire, these functions can return conflicting information.
	local hasGuildInfo = GetGuildInfo("player") ~= nil
	local hasGuildMemberCount = GetNumGuildMembers() ~= 0
	if IsInGuild() then
		local hasGuildOwner = self:GetGuildOwner() ~= nil
		return not hasGuildInfo or not hasGuildMemberCount or not hasGuildOwner
	else
		return hasGuildInfo or hasGuildMemberCount
	end
end

function module:UpdateFaction()
	local nameAndRealm = self:GetCharacterNameAndRealm()
	local character = self:GetCharacter(nameAndRealm)
	local faction = UnitFactionGroup("player")
	character.faction = faction and faction:lower() or "neutral"

	self:SendMessage("GoldStockSummary_CharacterMoneyUpdated", nameAndRealm)
end

function module:UpdateMoney()
	local nameAndRealm = self:GetCharacterNameAndRealm()
	local character = self:GetCharacter(nameAndRealm)
	character.copper = GetMoney()
	character.lastUpdate = time()

	self:SendMessage("GoldStockSummary_CharacterMoneyUpdated", nameAndRealm)
end

function module:UpdateAccountBankMoney()
	local accountBank = self:GetAccountBank()
	accountBank.copper = C_Bank.FetchDepositedMoney(Enum.BankType.Account)
	accountBank.lastUpdate = time()
	self:SendMessage("GoldStockSummary_AccountBankMoneyUpdated")
end

function module:UpdateGuildAndOwner()
	if self:IsInBrokenState() then
		if self.db.profile.debugMode then
			self:Print("guild info in broken state, retrying")
		end
		C_Timer.After(1, function()
			self:UpdateGuildAndOwner()
		end)
		return
	end

	local nameAndRealm = self:GetCharacterNameAndRealm()
	local character = self:GetCharacter(nameAndRealm)
	character.guild = IsInGuild() and self:GetGuildNameAndRealm() or nil
	self:ForceUpdateOwner()
end

function module:UpdateOwner()
	if self:IsInBrokenState() then
		if self.db.profile.debugMode then
			self:Print("guild info in broken state, retrying")
		end
		C_Timer.After(1, function()
			self:UpdateOwner()
		end)
		return
	end
	self:ForceUpdateOwner()
end

function module:ForceUpdateOwner()
	if IsInGuild() then
		local nameAndRealm = self:GetGuildNameAndRealm()
		local guild = self:GetGuild(nameAndRealm)
		local guildOwner = self:GetGuildOwner()
		if guildOwner then
			guild.owner = guildOwner
		else
			error("not in broken state, so guild owner should not be nil")
		end
		self:SendMessage("GoldStockSummary_CharacterMoneyUpdated", guild.owner)
		self:SendMessage("GoldStockSummary_GuildMoneyUpdated", nameAndRealm)
	end
end

---@param _ unknown
---@param type Enum.PlayerInteractionType
function module:PLAYER_INTERACTION_MANAGER_FRAME_SHOW(_, type)
	if type == Enum.PlayerInteractionType.GuildBanker then
		self:UpdateGuildBankMoney()
	end
end

function module:UpdateGuildBankMoney()
	if IsInGuild() then
		local nameAndRealm = self:GetGuildNameAndRealm()
		local guild = self:GetGuild(nameAndRealm)
		guild.copper = GetGuildBankMoney()
		self:SendMessage("GoldStockSummary_GuildMoneyUpdated", nameAndRealm)
	end
end

---@return string?
function module:GetGuildOwner()
	for i = 1, GetNumGuildMembers() do
		local name, _, rankIndex = GetGuildRosterInfo(i)
		if rankIndex == 0 then
			return name
		end
	end
end

---@param nameAndRealm string
---@return TrackedCharacter
function module:GetCharacter(nameAndRealm)
	local db = self.db.global
	if not db.characters[nameAndRealm] then
		db.characters[nameAndRealm] = {}
	end
	return db.characters[nameAndRealm]
end

---@return TrackedAccountBank
function module:GetAccountBank()
	local db = self.db.global
	if not db.accountBank then
		db.accountBank = {
			copper = 0,
			lastUpdate = 0,
		}
	end
	return db.accountBank
end

---@param nameAndRealm string
---@return TrackedGuild
function module:GetGuild(nameAndRealm)
	local db = self.db.global
	if not db.guilds[nameAndRealm] then
		db.guilds[nameAndRealm] = {}
		self:SendMessage("GoldStockSummary_GuildAdded", nameAndRealm)
	end
	return db.guilds[nameAndRealm]
end

function module:GetCharacterNameAndRealm()
	local name = UnitName("player")
	local realm = GetNormalizedRealmName()
	return string.format("%s-%s", name, realm)
end

function module:GetGuildNameAndRealm()
	-- The realm name returned by GetGuildInfo is normalized and there's nothing we can do about that
	local guildName, _, _, guildRealm = GetGuildInfo("player")
	if not guildRealm then
		guildRealm = GetNormalizedRealmName()
	end
	return string.format("%s-%s", guildName, guildRealm)
end
