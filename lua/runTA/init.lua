local runner = require("runTA.runner")
local commands = require("runTA.commands")

local function setup_runTA()
	commands.setup({
		output_window_configs = {
			width = 80,
			height = 20,
			position = "center",
			transparent = false,
		},
	})

	runner.setup()
end

setup_runTA()
