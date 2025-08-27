vim.pack.add({
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" }, -- none-ls and telescope dependency
})

require("telescope").setup({
	pickers = {
		find_files = {
			find_command = { "rg", "--ignore", "-L", "--hidden", "--files" },
		},
	},
})
