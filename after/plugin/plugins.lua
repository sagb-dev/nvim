local M = {}

function M.setup()
	-- vim.pack.add({ { src = "https://github.com/rainbowhxch/accelerated-jk.nvim" } })
	-- require("accelerated-jk").setup({
	-- 	enable_deceleration = true,
	-- })
	-- vim.api.nvim_set_keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
	-- vim.api.nvim_set_keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})

	vim.pack.add({ { src = "https://github.com/m4xshen/autoclose.nvim" } })
	require("autoclose").setup()

	vim.pack.add({
		{ src = "https://github.com/numToStr/Comment.nvim" },
		{ src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
	})
	require("ts_context_commentstring").setup({ enable_autocmd = false })
	require("Comment").setup({
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	})

	-- vim.pack.add({ { src = "https://github.com/ahmedkhalf/project.nvim" } })
	-- require("project_nvim").setup({
	-- 	manual_mode = false,
	-- 	detection_methods = { "lsp", "pattern" },
	-- 	patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
	-- 	ignore_lsp = {},
	-- 	exclude_dirs = {},
	-- 	show_hidden = false,
	-- 	silent_chdir = true,
	-- 	scope_chdir = "global",
	-- 	datapath = vim.fn.stdpath("data"),
	-- })

	vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround" } })
	require("nvim-surround").setup()
end

vim.defer_fn(M.setup, 1000)
-- M.setup()

return M
