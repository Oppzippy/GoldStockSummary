local widgetType, widgetVersion = "GoldTracker-ScrollingTable", 1

local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable")

local methods = {
	OnAcquire = function(self)
		self.scrollingTable:EnableSelection(false)
	end,
	OnRelease = function(self)
		self.scrollingTable:SetData({})
	end,
	SetDisplayCols = function(self, ...)
		self.scrollingTable:SetDisplayCols(...)
	end,
	SetData = function(self, ...)
		self.scrollingTable:SetData(...)
	end,
	SetFilter = function(self, ...)
		self.scrollingTable:SetFilter(...)
	end,
	EnableSelection = function(self, flag)
		self.scrollingTable:EnableSelection(flag)
	end,
	GetSelection = function(self, ...)
		return self.scrollingTable:GetSelection()
	end,
	GetRow = function(self, ...)
		return self.scrollingTable:GetRow(...)
	end,
}

do
	local function constructor()
		local scrollingTable = ScrollingTable:CreateST({})
		scrollingTable:Hide()

		local widget = {
			type = widgetType,
			frame = scrollingTable.frame,
			scrollingTable = scrollingTable,
		}

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
