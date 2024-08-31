local M = {}

local function create_floating_term()
	-- Get the dimensions of the Neovim window
	local width = 80
	local height = 20

	-- Calculate the position for the floating window
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)

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

	local buf = create_floating_term()
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running code..." })

	vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			if data then
				vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
			end
		end,
		on_stderr = function(_, data, _)
			if data then
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

function M.setup()
	vim.api.nvim_create_user_command("RunCode", run_code, {})
end

return M
