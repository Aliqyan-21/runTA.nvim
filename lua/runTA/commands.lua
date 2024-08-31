local M = {}

local function create_floating_term(config)
	config = config or {}
	local width = config.width or 80
	local height = config.height or 20
	local position = config.position or "center"

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
		-- Handle custom positions with default values if not provided
		col = config.custom_col or math.floor((vim.o.columns - width) / 2)
		row = config.custom_row or math.floor((vim.o.lines - height) / 2)
	else
		vim.api.nvim_err_writeln("Invalid position: " .. position)
		return nil
	end

	-- Ensure col and row are valid integers
	col = math.max(col or 0, 0)
	row = math.max(row or 0, 0)

	-- Create the floating terminal window
	local buf = vim.api.nvim_create_buf(false, true)
	if not buf then
		vim.api.nvim_err_writeln("Failed to create buffer")
		return nil
	end

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	return buf
end

local function run_code()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p") -- Get the full path of the current file
	local command

	if ft == "c" then
		command = "gcc -o temp " .. filename .. " && ./temp"
	elseif ft == "cpp" then
		command = "g++ -o temp " .. filename .. " && ./temp"
	else
		vim.api.nvim_err_writeln("Unsupported filetype: " .. ft)
		return
	end

	-- Get user-defined configuration
	local config = vim.g.runTA_config or {}

	local buf = create_floating_term(config)
	if not buf then
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running code..." })

	vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			if data and #data > 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
		on_stderr = function(_, data, _)
			if data and #data > 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
		on_exit = function(_, code, _)
			if code == 0 then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Execution finished successfully" })
			else
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "Execution failed with code " .. code })
			end
		end,
		stdout_buffered = true,
		stderr_buffered = true,
	})
end

function M.setup(config)
	vim.g.runTA_config = config or {}
	vim.api.nvim_create_user_command("RunCode", run_code, {})
end

return M
