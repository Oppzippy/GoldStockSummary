local widgetType, widgetVersion = "GoldTracker-ScrollingTable", 1

local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable")

local methods = {
	OnAcquire = function(self)
		self.scrollingTable:EnableSelection(false)
		self.scrollingTable:SetFilter(function() return true end)
	end,
	OnRelease = function(self)
		self.scrollingTable:ClearSelection()
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
	local function postHook(object, method, func)
		local oldFunc = object[method]
		object[method] = function(...)
			oldFunc(...)
			func()
		end
	end

	local function constructor()
		local scrollingTable = ScrollingTable:CreateST({})
		scrollingTable:Hide()

		local widget = {
			type = widgetType,
			frame = scrollingTable.frame,
			scrollingTable = scrollingTable,
		}

		-- lib-st doesn't have an event for selection change, so we have to hook related functions
		local function fireSelectionChanged()
			if not widget:IsReleasing() then
				widget:Fire("OnSelectionChanged")
			end
		end

		postHook(scrollingTable, "SetSelection", fireSelectionChanged)
		postHook(scrollingTable, "ClearSelection", fireSelectionChanged)

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
