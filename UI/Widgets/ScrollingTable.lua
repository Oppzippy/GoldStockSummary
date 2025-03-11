local widgetType, widgetVersion = "GoldStockSummary-ScrollingTable", 1

local AceGUI = LibStub("AceGUI-3.0")
local ScrollingTable = LibStub("ScrollingTable")

local methods = {
	OnAcquire = function(self)
		self.scrollingTable:EnableSelection(false)
		self.scrollingTable:SetFilter(function() return true end)
		self.scrollingTable:Show()
	end,
	OnRelease = function(self)
		self.scrollingTable:ClearSelection()
		self.scrollingTable:SetData({})
		self.scrollingTable:Hide()
	end,
	SetDisplayCols = function(self, cols, ...)
		self.scrollingTable:SetDisplayCols(cols, ...)

		local numCols = #cols
		for i, col in next, self.scrollingTable.head.cols do
			if i <= numCols then
				col:Show()
			else
				col:Hide()
			end
		end
		for _, row in next, self.scrollingTable.rows do
			for i, col in next, row.cols do
				if i <= numCols then
					col:Show()
					col.text:Show()
				else
					col:Hide()
					col.text:Hide()
				end
			end
		end
	end,
	SetData = function(self, ...)
		self.scrollingTable:SetData(...)
	end,
	SetFilter = function(self, ...)
		self.scrollingTable:SetFilter(...)
	end,
	SetSort = function(self, columnIndex, direction)
		for i, column in next, self.scrollingTable.cols do
			if i == columnIndex then
				column.sort = direction
			else
				column.sort = nil
			end
		end
		self.scrollingTable:SortData()
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

		local function fireSortingChanged()
			for i, col in next, widget.scrollingTable.cols do
				if col.sort then
					-- col.sort is either ScrollingTable.SORT_ASC or ScrollingTable.SORT_DSC
					widget:Fire("OnSortingChanged", i, col.sort)
					break
				end
			end
		end

		postHook(scrollingTable, "SetSelection", fireSelectionChanged)
		postHook(scrollingTable, "ClearSelection", fireSelectionChanged)

		widget.scrollingTable:RegisterEvents({
			OnClick = function(rowFrame, cellFrame, data, cols, row, realrow, column, table, button)
				if button == "LeftButton" then
					if not (row or realrow) then
						-- Our event handler doesn't run before lib-st's event handler that sets col.sort,
						-- so wait until the next frame to ensure the sorting column is set properly
						C_Timer.After(0, function()
							fireSortingChanged()
						end)
					end
				end
			end
		})

		for method, func in next, methods do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, constructor, widgetVersion)
end
