local runTA = require("runTA.commands")

local function setup_runTA()
	runTA.setup({
		output_window_type = "floating",
		output_window_configs = {
			width = 80,
			height = 20,
			position = "center",
			custom_col = nil,
			custom_row = nil,
			transparent = false,
		},
	})
end

setup_runTA()
