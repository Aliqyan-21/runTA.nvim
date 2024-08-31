local runTA = require("runTA.commands")

local function setup_runTA()
	runTA.setup({
		output_window_configs = {
			width = 80, -- Default width of the floating window
			height = 20, -- Default height of the floating window
			position = "center", -- Default position (can be "center", "top", "bottom", "left", "right", "custom")
			custom_col = nil, -- Column position for custom placement (optional)
			custom_row = nil, -- Row position for custom placement (optional)

			transparent = false, -- true for a transparent background
		},
	})
end

setup_runTA()
