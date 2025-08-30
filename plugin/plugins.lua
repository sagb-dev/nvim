-- vim.pack.add({ "https://github.com/chrisgrieser/nvim-origami" })
-- vim.opt.foldlevel = 99
-- vim.opt.foldlevelstart = 99
-- require("origami").setup()

vim.schedule(function()
	vim.pack.add({
		"https://github.com/numToStr/Comment.nvim",
		"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
		"https://github.com/lewis6991/gitsigns.nvim",
		"https://github.com/nvim-mini/mini.nvim",
		"https://github.com/tzachar/local-highlight.nvim",
	})
	require("ts_context_commentstring").setup({ enable_autocmd = false })
	require("Comment").setup({
		pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
	})
	require("mini.pairs").setup()
	require("mini.surround").setup()
	require("gitsigns").setup({
		signcolumn = false, -- Toggle with `:Gitsigns toggle_signs`
		numhl = true, -- Toggle with `:Gitsigns toggle_numhl`
		-- linehl = true,
		current_line_blame = true,
		current_line_blame_opts = {
			virt_text = true,
			virt_text_pos = "right_align",
		},
	})
	require("local-highlight").setup({
		animate = {
			enabled = false,
		},
	})
	vim.cmd("LocalHighlightOn")
end)

-- vim.cmd([[
-- echo 'something'
-- ]])
