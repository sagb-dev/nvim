local gh = "https://github.com/"

vim.pack.add({ { src = gh .. "chrisgrieser/nvim-origami" } })
require("origami").setup()
vim.o.foldlevelstart = 1

vim.schedule(function()
	vim.pack.add({
		{ src = gh .. "numToStr/Comment.nvim" },
		{ src = gh .. "lewis6991/gitsigns.nvim" },
		{ src = gh .. "nvim-mini/mini.nvim" },
		{ src = gh .. "tzachar/local-highlight.nvim" },
		{ src = gh .. "ThePrimeagen/refactoring.nvim" },
		{ src = gh .. "JoosepAlviste/nvim-ts-context-commentstring" },
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
	require("refactoring").setup()
end)

-- vim.cmd([[
-- echo 'something'
-- ]])
