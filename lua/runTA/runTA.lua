local commands = require("runTA.commands")
local runner = require("runTA.runner")

local M = {}

local function setup(config)
	-- Set up commands with the provided configuration
	commands.setup(config)

	-- Set up the user command for running code
	runner.setup()
end

M.setup = setup

return M
