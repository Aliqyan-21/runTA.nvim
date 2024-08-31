local commands = require("runTA.commands")
local runner = require("runTA.runner")

local function setup_runTA()
	commands.setup({
		output_window_configs = {
			width = 80,
			height = 20,
			position = "center",
			custom_col = nil,
			custom_row = nil,
			transparent = false,
		},
	})

	vim.api.nvim_create_user_command("RunCode", function()
		runner.run_code()
	end, {})
end

setup_runTA()
