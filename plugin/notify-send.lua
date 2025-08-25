local M = {}

--- @return function
function M.setup()
	vim.notify = M.notify_send
	return vim.notify
end

--- @param level integer
--- @return string
function M.get_urgency(level)
	local urgency = {
		[vim.log.levels.TRACE] = "low", -- 0
		[vim.log.levels.DEBUG] = "low", -- 1
		[vim.log.levels.INFO] = "normal", -- 2
		[vim.log.levels.WARN] = "normal", -- 3
		[vim.log.levels.ERROR] = "critical", -- 4
	}
	return urgency[level] or "normal"
end

--- @param msg string
--- @param level integer
--- @return nil
function M.notify_send(msg, level)
	if vim.fn.executable("notify-send") == 0 then
		vim.schedule(function()
			vim.notify("`notify-send` is not available in the host", vim.log.levels.INFO)
		end)
		return
	end

	vim.system({
		"notify-send",
		"--icon",
		"nvim",
		"--urgency",
		M.get_urgency(level),
		"Neovim",
		msg,
	})
end

vim.schedule(M.setup)

return M
