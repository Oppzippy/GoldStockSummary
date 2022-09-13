local component = {
	{
		create = function(container)
			return widgets
		end,
		update = function(widgets)

		end,
		watch = {
			store,
		}
	}
}
