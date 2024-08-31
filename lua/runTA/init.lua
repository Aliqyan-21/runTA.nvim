local runTA = require("runTA.commands")

local function setup_runTA()
	-- Set up the plugin with organized configuration categories
	runTA.setup({
		output_window_configs = {
			width = 80, -- Default width of the floating window
			height = 20, -- Default height of the floating window
			position = "center", -- Default position (can be "center", "top", "bottom", "left", "right", "custom")
			custom_col = nil, -- Column position for custom placement (optional)
			custom_row = nil, -- Row position for custom placement (optional)
		},
		-- Future configurations can go here, under different categories
	})
end

setup_runTA()
