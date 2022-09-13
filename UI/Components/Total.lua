---@type string
local addonName = ...
---@class ns
local ns = select(2, ...)
---@class ns.Components
local components = ns.Components

local AceGUI = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")

local L = AceLocale:GetLocale(addonName)

---@param justifyH "LEFT"|"CENTER"|"RIGHT"
---@param text? string
local function createCell(justifyH, text)
	local cell = AceGUI:Create("Label")
	---@cast cell AceGUILabel
	cell:SetFullWidth(true)
	cell:SetFontObject("GameFontHighlightMedium")
	cell:SetJustifyH(justifyH)
	if text then
		cell:SetText(text)
	end
	return cell
end

---@type Component
components.Total = {
	---@param container AceGUIContainer
	create = function(container)
		container:SetLayout("Table")
		container:SetUserData("table", {
			columns = {
				{
					width = 0.5,
					alignH = "RIGHT",
				},
				{
					width = 0.5,
					alignH = "LEFT",
				},
			},
			space = 5,
		})
		local cells = {
			createCell("RIGHT", L.total_money),
			createCell("LEFT"),
			createCell("RIGHT", L.total_personal_money),
			createCell("LEFT"),
			createCell("RIGHT", L.total_guild_bank_money),
			createCell("LEFT"),
		}
		for _, cell in ipairs(cells) do
			container:AddChild(cell)
		end
		return cells
	end,
	update = function(cells)
		local state = ns.TotalMoneyStore:GetState()
		ViragDevTool_AddData(ns.TotalMoneyStore)
		cells[2]:SetText(GetMoneyString(state.total, true))
		cells[4]:SetText(GetMoneyString(state.personalTotal, true))
		cells[6]:SetText(GetMoneyString(state.guildBankTotal, true))
	end,
	watch = { ns.TotalMoneyStore },
}
