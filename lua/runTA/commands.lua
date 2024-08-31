local M = {}

-- Store the buffer and window IDs globally to reopen later
local output_buf = nil
local output_win = nil

-- Function to focus the floating window
local function focus_floating_win()
	if output_win and vim.api.nvim_win_is_valid(output_win) then
		vim.api.nvim_set_current_win(output_win)
		-- Set the window to accept input
		vim.api.nvim_command("stopinsert") -- Exit insert mode to focus
	else
		vim.api.nvim_err_writeln("Floating window is not valid.")
	end
end

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
	else
		vim.api.nvim_err_writeln("Invalid position: " .. position)
		return
	end

	-- Ensure col and row are integers
	col = col or 0
	row = row or 0

	-- Create the floating terminal window
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
		focusable = true, -- Make the window focusable
	})

	-- Apply transparency settings
	local transparent = window_configs.transparent or false
	vim.api.nvim_set_option_value("winblend", (not transparent) and 20 or 0, { scope = "local" })
	vim.api.nvim_set_option_value("winhighlight", "Normal:Normal,FloatBorder:Normal", { scope = "local" })

	return buf, win
end

local function run_code()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p") -- Get the full path of the current file
	local command

	if ft == "c" then
		command = "gcc -o temp " .. filename .. " && ./temp"
	elseif ft == "cpp" then
		command = "g++ -o temp " .. filename .. " && ./temp"
	elseif ft == "python" then
		command = "python " .. filename
	elseif ft == "java" then
		command = "java " .. filename
	elseif ft == "javascript" then
		command = "node " .. filename
	elseif ft == "typescript" then
		command = "node " .. filename
	elseif ft == "ruby" then
		command = "ruby " .. filename
	elseif ft == "lua" then
		command = "lua " .. filename
	elseif ft == "go" then
		command = "go run " .. filename
	elseif ft == "rust" then
		command = "rustc -o temp " .. filename .. " && ./temp"
	elseif ft == "bash" then
		command = "bash " .. filename
	elseif ft == "r" then
		command = "Rscript " .. filename
	elseif ft == "swift" then
		command = "swift " .. filename
	elseif ft == "haskell" then
		command = "runhaskell " .. filename
	elseif ft == "kotlin" then
		command = "kotlinc " .. filename .. " -include-runtime -d temp.jar && java -jar temp.jar"
	else
		vim.api.nvim_err_writeln("Unsupported filetype: " .. ft)
		return
	end

	-- Get user-defined configuration
	local config = vim.g.runTA_config or {}

	-- Create or reuse the floating terminal window
	output_buf, output_win = create_floating_term(config)

	if not output_buf then
		return
	end

	-- Open a terminal and run the command interactively
	vim.fn.termopen(command, {
		on_exit = function(_, code, _)
			if vim.api.nvim_buf_is_valid(output_buf) then
				-- Ensure buffer is modifiable before setting lines
				vim.bo[output_buf].modifiable = true
				if code == 0 then
					vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "Execution finished successfully" })
				else
					vim.api.nvim_buf_set_lines(output_buf, -1, -1, false, { "Execution failed with code " .. code })
				end
				-- Make buffer read-only again
				vim.bo[output_buf].modifiable = false
			end
			-- Focus the floating window after code execution
			focus_floating_win()
		end,
	})

	-- Switch the terminal to normal mode after execution
	vim.cmd("startinsert!")

	-- Key mapping to quit the window
	vim.api.nvim_buf_set_keymap(output_buf, "n", "q", ":q<CR>", { noremap = true, silent = true })

	-- Optionally, avoid closing the window on Esc or other key presses
	-- Set autocmd to prevent unwanted window closure
	vim.cmd([[
		augroup RunTA
			autocmd!
			autocmd BufLeave <buffer> stopinsert
		augroup END
	]])
end

-- Reopen the floating terminal to view the last output
local function reopen_last_output()
	if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
		-- Ensure output_win is valid
		if output_win and vim.api.nvim_win_is_valid(output_win) then
			local win_width = vim.api.nvim_win_get_width(output_win)
			local win_height = vim.api.nvim_win_get_height(output_win)
			local win_position = vim.api.nvim_win_get_position(output_win)

			-- Reopen the window using the previous dimensions and position
			vim.api.nvim_open_win(output_buf, true, {
				relative = "editor",
				width = win_width,
				height = win_height,
				col = win_position[2],
				row = win_position[1],
				style = "minimal",
				border = "rounded",
				focusable = true, -- Ensure the window is focusable
			})
		else
			-- Handle the case where output_win is nil or invalid
			local width = 80
			local height = 20
			local col = math.floor((vim.o.columns - width) / 2)
			local row = math.floor((vim.o.lines - height) / 2)

			output_win = vim.api.nvim_open_win(output_buf, true, {
				relative = "editor",
				width = width,
				height = height,
				col = col,
				row = row,
				style = "minimal",
				border = "rounded",
				focusable = true, -- Ensure the window is focusable
			})
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
