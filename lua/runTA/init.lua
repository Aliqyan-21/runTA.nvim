local runTA = require("runTA.commands")

local function setup_runTA()
	-- configurations
	runTA.setup({
		width = 80,
		height = 20,
		position = "center", -- "center", "top", "bottom", "left", "right", "custom"
		custom_col = nil, -- Column position for custom placement (optional)
		custom_row = nil, -- Row position for custom placement (optional)
	})
end

setup_runTA()
