local runTA = require("runTA.commands")

local function setup_runTA()
	runTA.setup({
		output_window_configs = {
			width = 80, -- Default width of the floating window
			height = 20, -- Default height of the floating window
			position = "center", -- Default position (can be "center", "top", "bottom", "left", "right", "custom")
			custom_col = nil, -- Column position for custom placement (optional)
			custom_row = nil, -- Row position for custom placement (optional)

			bg_color = "None", -- Use "None" for transparency or a valid highlight group
			border_color = "None", -- Use "None" for no color or a valid highlight group
			transparency = 0, -- Transparency (set a value between 0-100)
		},
	})
end

setup_runTA()
