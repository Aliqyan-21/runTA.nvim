local runTA = require("runTA")

local function setup_runTA()
	runTA.setup({
		output_window_configs = {
			width = 80,
			height = 20,
			position = "center",
			custom_col = nil,
			custom_row = nil,
			transparent = false, -- true for a transparent background
		},
	})
end

setup_runTA()
