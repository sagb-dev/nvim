local M = {}

local count = 0

vim.o.scrolloff = 9999
vim.o.sidescrolloff = 9999
-- vim.o.scrolloff = 3
-- vim.o.sidescrolloff = 3
-- vim.o.scrolljump = -90 -- scroll like emacs

function M.trigger_center()
	count = count + 1
	if count == vim.api.nvim_win_get_height(0) / 2 then
		vim.o.scrolloff = 9999
		vim.o.sidescrolloff = 9999
	end
end

function M.setup()
	vim.keymap.set("n", "j", function()
		M.trigger_center()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
	end, { expr = true, silent = true }) -- Move down, but use 'gj' if no count is given
	vim.keymap.set("n", "k", function()
		M.trigger_center()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
	end, { expr = true, silent = true }) -- Move up, but use 'gk' if no count is given

	vim.api.nvim_create_autocmd("CursorHold", {
		callback = function()
			vim.o.scrolloff = 3
			vim.o.sidescrolloff = 3
			count = 0
		end,
	})
end

-- M.setup()

return M
