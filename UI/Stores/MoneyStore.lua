---@class ns
local ns = select(2, ...)

local actions = {
	setCharacters = function(state, action)
		state.characters = action.characters
		return state
	end,
	setAccountBank = function(state, action)
		state.accountBank = action.accountBank
		return state
	end,
	setGuilds = function(state, action)
		state.guilds = action.guilds
		return state
	end,
	updateCharacter = function(state, action)
		state.characters[action.name] = action.character
		return state
	end,
	updateGuild = function(state, action)
		state.guilds[action.name] = action.guild
		return state
	end,
	deleteCharacter = function(state, action)
		state.characters[action.name] = nil
		return state
	end,
	deleteGuild = function(state, action)
		state.guilds[action.name] = nil
		return state
	end,
}

local function reducer(state, action)
	local actionFunc = actions[action.type]
	if actionFunc then
		return actionFunc(state, action)
	end
	error(string.format("unknown action: %s", action.type))
end

ns.MoneyStore = ns.Store.Create(reducer, {
	characters = {},
	guilds = {},
})

ns.UIFramework:RegisterGlobalStore(ns.MoneyStore)
