vim.defer_fn(function()
	-- 1 accelerated-jk
	vim.pack.add({ { src = "https://github.com/rainbowhxch/accelerated-jk.nvim" } })
	require("accelerated-jk").setup({
		enable_deceleration = true,
	})
	vim.api.nvim_set_keymap("n", "j", "<Plug>(accelerated_jk_gj)", {})
	vim.api.nvim_set_keymap("n", "k", "<Plug>(accelerated_jk_gk)", {})

	-- 2 surround
	vim.pack.add({ { src = "https://github.com/m4xshen/autoclose.nvim" } })
	require("autoclose").setup()

	-- 3 comments and others
	vim.pack.add({
		{ src = "https://github.com/numToStr/Comment.nvim" },
		{ src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
	})
	require("ts_context_commentstring").setup({ enable_autocmd = false })
	require("Comment").setup({
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	})

	-- 4 project
	vim.pack.add({ { src = "https://github.com/ahmedkhalf/project.nvim" } })
	require("project_nvim").setup({
		manual_mode = false,
		detection_methods = { "lsp", "pattern" },
		patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
		ignore_lsp = {},
		exclude_dirs = {},
		show_hidden = false,
		silent_chdir = true,
		scope_chdir = "global",
		datapath = vim.fn.stdpath("data"),
	})

	-- 5 surround
	vim.pack.add({ { src = "https://github.com/kylechui/nvim-surround" } })
	require("nvim-surround").setup()

	-- 6 ts and others
	vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" } })
	require("treesitter-context").setup()

	-- 7 vcs tools
	vim.pack.add({ { src = "https://github.com/lewis6991/gitsigns.nvim" } })
	require("gitsigns").setup({
		signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
		numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
	})

	-- 8 telescope
	vim.pack.add({ { src = "https://github.com/nvim-telescope/telescope.nvim" } })
	require("telescope").setup({
		pickers = {
			find_files = {
				find_command = { "rg", "--ignore", "-L", "--hidden", "--files" },
			},
		},
	})
	local builtin = require("telescope.builtin")
	vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
	vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
	vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
	vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
end, 1000)
