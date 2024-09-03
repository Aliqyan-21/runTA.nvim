local M = {}

-- Store the buffer and window IDs globally for reopening window
local output_buf = nil
local output_win = nil

-- Function to focus the window
local function focus_window()
	if output_win and vim.api.nvim_win_is_valid(output_win) then
		vim.api.nvim_set_current_win(output_win)
		vim.api.nvim_command("stopinsert") -- Exit insert mode to focus
	else
		vim.api.nvim_err_writeln("Window is not valid.")
	end
end

-- Function to create a floating terminal window
local function create_floating_term(config)
	config = config or {}
	local window_configs = config.output_window_configs or {}

	local width = window_configs.width or 80
	local height = window_configs.height or 20
	local position = window_configs.position or "center"

	local col, row

	-- Calculate the position for the floating window
	local positions = {
		center = function()
			col = math.floor((vim.o.columns - width) / 2)
			row = math.floor((vim.o.lines - height) / 2)
		end,
		bottom = function()
			col = math.floor((vim.o.columns - width) / 2)
			row = vim.o.lines - height - 1
		end,
		top = function()
			col = math.floor((vim.o.columns - width) / 2)
			row = 0
		end,
		right = function()
			col = vim.o.columns - width - 1
			row = math.floor((vim.o.lines - height) / 2)
		end,
		left = function()
			col = 0
			row = math.floor((vim.o.lines - height) / 2)
		end,
		custom = function()
			col = window_configs.custom_col or math.floor((vim.o.columns - width) / 2)
			row = window_configs.custom_row or math.floor((vim.o.lines - height) / 2)
		end,
	}

	if positions[position] then
		positions[position]()
	else
		vim.api.nvim_err_writeln("Invalid position: " .. position)
		return
	end

	col = col or 0
	row = row or 0

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		focusable = true,
	})

	local transparent = window_configs.transparent or false
	vim.api.nvim_set_option_value("winblend", (not transparent) and 20 or 0, { scope = "local" })
	vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:Normal", { scope = "local" })

	return buf, win
end

-- Function to create a pane window
local function create_pane_window(config)
	config = config or {}
	local window_configs = config.output_window_configs or {}
	local height = window_configs.height or 10

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	-- Create a horizontal split at the bottom
	vim.cmd("botright split")
	vim.api.nvim_win_set_height(0, height)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	return buf, win
end

-- Function to create a split window
local function create_split_window(config)
	config = config or {}
	local window_configs = config.output_window_configs or {}
	local width = window_configs.width or 40

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	-- Create a vertical split
	vim.cmd("vsplit")
	vim.api.nvim_win_set_width(0, width)
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	return buf, win
end

-- Function to create a tab window
local function create_tab_window(config)
	config = config or {}

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)
	-- Create a new tab
	vim.cmd("tabnew")
	local win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)

	return buf, win
end

-- Function to create the output window based on the configured type
local function create_output_window(config)
	local window_type = config.output_window_type or "floating"

	if window_type == "floating" then
		return create_floating_term(config)
	elseif window_type == "pane" then
		return create_pane_window(config)
	elseif window_type == "tab" then
		return create_tab_window(config)
	elseif window_type == "split" then
		return create_split_window(config)
	else
		vim.api.nvim_err_writeln("Unsupported window type: " .. window_type)
		return nil, nil
	end
end

-- Function to run the code in the output window
local function run_code()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p") -- Get the full path of the current file

	local command_map = {
		c = "gcc -o temp " .. filename .. " && ./temp",
		cpp = "g++ -o temp " .. filename .. " && ./temp",
		python = "python " .. filename,
		java = "java " .. filename,
		javascript = "node " .. filename,
		typescript = "node " .. filename,
		ruby = "ruby " .. filename,
		lua = "lua " .. filename,
		go = "go run " .. filename,
		rust = "rustc -o temp " .. filename .. " && ./temp",
		sh = "bash " .. filename,
		r = "Rscript " .. filename,
		swift = "swift " .. filename,
		haskell = "runhaskell " .. filename,
		kotlin = "kotlinc " .. filename .. " -include-runtime -d temp.jar && java -jar temp.jar",
	}

	local command = command_map[ft]

	if not command then
		vim.api.nvim_err_writeln("Unsupported filetype: " .. ft)
		return
	end

	local config = vim.g.runTA_config or {}

	output_buf, output_win = create_output_window(config)

	if not output_buf then
		return
	end

	vim.fn.termopen(command, {
		on_exit = function(_, code, _)
			if vim.api.nvim_buf_is_valid(output_buf) then
				vim.bo[output_buf].modifiable = true
				local result_msg = code == 0 and "Execution finished successfully"
					or "Execution failed with code " .. code
				vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { result_msg })
				vim.bo[output_buf].modifiable = false
			end
			focus_window()
		end,
	})

	vim.cmd("startinsert!")

	vim.api.nvim_buf_set_keymap(output_buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

	vim.cmd([[
        augroup RunTA
            autocmd!
            autocmd BufLeave <buffer> stopinsert
        augroup END
    ]])
end

local function reopen_last_output()
	if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
		if output_win and vim.api.nvim_win_is_valid(output_win) then
			vim.api.nvim_set_current_win(output_win)
		else
			local config = vim.g.runTA_config or {}
			local window_type = config.output_window_type or "floating"

			if window_type == "floating" then
				output_win = vim.api.nvim_open_win(output_buf, true, {
					relative = "editor",
					width = config.output_window_configs.width or 80,
					height = config.output_window_configs.height or 20,
					col = config.output_window_configs.col or 0,
					row = config.output_window_configs.row or 0,
					style = "minimal",
					border = "rounded",
					focusable = true,
				})
			elseif window_type == "pane" then
				vim.cmd("botright split")
				vim.api.nvim_win_set_height(0, config.output_window_configs.height or 10)
				output_win = vim.api.nvim_get_current_win()
			elseif window_type == "tab" then
				vim.cmd("tabnew")
				output_win = vim.api.nvim_get_current_win()
			elseif window_type == "split" then
				vim.cmd("vsplit")
				vim.api.nvim_win_set_width(0, config.output_window_configs.width or 40)
				output_win = vim.api.nvim_get_current_win()
			else
				vim.api.nvim_err_writeln("Unsupported window type: " .. window_type)
				return
			end

			if output_win and vim.api.nvim_win_is_valid(output_win) then
				vim.api.nvim_win_set_buf(output_win, output_buf)
				vim.api.nvim_set_current_win(output_win)
				vim.api.nvim_command("stopinsert") -- Exit insert mode to focus
			else
				vim.api.nvim_err_writeln("Failed to reopen the last output window.")
			end
		end
	else
		vim.api.nvim_err_writeln("No previous output to display.")
	end
end

function M.setup(config)
	vim.g.runTA_config = config or {}
	vim.api.nvim_create_user_command("RunCode", run_code, {})
	vim.api.nvim_create_user_command("ReopenLastOutput", reopen_last_output, {})
end

return M
