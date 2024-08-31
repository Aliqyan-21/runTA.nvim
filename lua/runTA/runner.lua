local M = {}

local function run_code()
	local ft = vim.bo.filetype
	local filename = vim.fn.expand("%:p")
	local command

	if ft == "c" then
		command = "gcc -o temp " .. filename .. " && ./temp"
	elseif ft == "cpp" then
		command = "g++ -o temp " .. filename .. " && ./temp"
	else
		vim.api.nvim_err_writeln("Unsupported filetype: " .. ft)
		return
	end

	local config = vim.g.runTA_config or {}
	local buf = require("runTA.commands").create_floating_term(config)

	if not buf then
		return
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Code Output:" })

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
