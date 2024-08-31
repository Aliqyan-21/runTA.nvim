local M = {}

local function create_floating_term(config)
	config = config or {}
	local window_configs = config.output_window_configs or {}

	local width = window_configs.width or 80
	local height = window_configs.height or 20
	local position = window_configs.position or "center"

	local col, row

	-- Calculate the position for the floating window
	if position == "center" then
		col = math.floor((vim.o.columns - width) / 2)
		row = math.floor((vim.o.lines - height) / 2)
	elseif position == "bottom" then
		col = math.floor((vim.o.columns - width) / 2)
		row = vim.o.lines - height - 1
	elseif position == "top" then
		col = math.floor((vim.o.columns - width) / 2)
		row = 0
	elseif position == "right" then
		col = vim.o.columns - width - 1
		row = math.floor((vim.o.lines - height) / 2)
	elseif position == "left" then
		col = 0
		row = math.floor((vim.o.lines - height) / 2)
	elseif position == "custom" then
		col = window_configs.custom_col or math.floor((vim.o.columns - width) / 2)
		row = window_configs.custom_row or math.floor((vim.o.lines - height) / 2)
	else
		vim.api.nvim_err_writeln("Invalid position: " .. position)
		return
	end

	-- Ensure col and row are integers
	col = col or 0
	row = row or 0

	-- Create the floating terminal window
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	-- Apply transparency settings
	local transparent = window_configs.transparent or false

	-- Set transparency (winblend)
	vim.api.nvim_set_option_value("winblend", (not transparent) and 20 or 0, { scope = "local" })

	-- Set window highlight groups to ensure no transparency
	vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:Normal", { scope = "local" })

	return buf
end

function M.setup(config)
	vim.g.runTA_config = config or {}
end

M.create_floating_term = create_floating_term -- Export function for use in other modules

return M
