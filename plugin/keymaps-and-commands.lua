local map = vim.keymap.set
local au = vim.api.nvim_create_autocmd
local cmd = vim.api.nvim_create_user_command

local disable = {
	"<space>",
	"<down>",
	"<up>",
	"<left>",
	"<right>",
	"<backspace>",
	"<enter>",
}

vim.iter(disable):map(function(opt)
	return map("n", opt, "<Nop>")
end)

map("n", "<cr>", "i<cr><esc>", { silent = true })

map("n", "gcy", "yygccp", { remap = true, silent = true, desc = "yank line, comment out and paste below" })
map("v", "gcy", "ygvgc`>p", { remap = true, silent = true, desc = "yank block, comment out and paste below" })
map("n", "gs", "`[v`]", { silent = true, desc = "goto last selection, this is yanked, changed or pasted text" })

map("n", "<a-j>", ":m .+1<CR>==", { silent = true, desc = "move selected line up or down" })
map("n", "<a-k>", ":m .-2<CR>==", { silent = true, desc = "move selected line up or down" })
map({ "x", "v" }, "<a-j>", ":m '>+1<CR>gv=gv", { silent = true, desc = "move selected block up or down" })
map({ "x", "v" }, "<a-k>", ":m '<-2<CR>gv=gv", { silent = true, desc = "move selected block up or down" })

map("v", ">", ">gv", { silent = true, desc = "keep the visual selection after shifting it" })
map("v", "<", "<gv", { silent = true, desc = "keep the visual selection after shifting it" })

map("n", "//", "/<up>", { desc = "go to last searched term" })
map("n", "<esc>", function()
	vim.snippet.stop()
	vim.cmd.nohlsearch()
end, { silent = true, desc = "turn off highlighted search term, and stop snippet input" })
map("n", "<leader>w", ":set wrap!<cr>", { silent = true, desc = "toggle wrap" })

map("n", "<leader>cc", vim.cmd.cclose, { silent = true, desc = "close quickfix list" })
au("FileType", {
	pattern = "qf",
	callback = function()
		map("n", "<c-j>", "<cmd>cnext<cr>", { silent = true, desc = "navigate quickfix list" })
		map("n", "<c-k>", "<cmd>cprev<cr>", { silent = true, desc = "navigate quickfix list" })
		-- vim.cmd.wincmd('L') -- In case you want the quickfix list to open to the right all the time
	end,
})

map("n", "<leader>ch", function()
	require("gitsigns").setqflist("all")
end)

map("i", ",", ",<c-g>u", { desc = "add break-points when you are insert mode" })
map("i", ".", ".<c-g>u", { desc = "add break-points when you are insert mode" })
map("i", "!", "!<c-g>u", { desc = "add break-points when you are insert mode" })
map("i", "?", "?<c-g>u", { desc = "add break-points when you are insert mode" })

map("n", "-", "<CMD>Oil --float<CR>", { desc = "open parent directory" })

map("n", "<leader>f", function()
	require("fff").find_files()
end, { desc = "fuzzy find project files" })

map("n", "<leader>tt", function()
	require("telescope.builtin").resume()
end, { desc = "Resume Telescope" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Telescope buffers" })
map("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end, { desc = "Telescope help tags" })

map("n", "gl", vim.diagnostic.open_float, { desc = "open current line diagnostics in a floating window" })
map("n", "]d", vim.diagnostic.open_float, { desc = "open current line diagnostics in a floating window" })
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, { desc = "goto next diagnostic" })
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, { desc = "goto previous diagnostic" })
map("n", "<leader>cd", vim.diagnostic.setqflist, { desc = "populate quickfix with diagnostics" })
map("n", "<leader>cdl", vim.diagnostic.setloclist, { desc = "populate quickfix with local diagnostics" })

cmd("ChangeDirectory", function()
	vim.fn.chdir(vim.fn.expand("%:p:h"))
	require("fff").change_indexing_directory(vim.fn.getcwd())
end, { desc = "change directory to be current buffer parent directory" })

au("LspAttach", {
	callback = function(args)
		local lsp_opts = {
			buffer = args.buf,
			silent = true,
		}

		-- :help lsp-defaults
		map("n", "gD", vim.lsp.buf.declaration, { unpack(lsp_opts), desc = "goto the declaration of symbol" })
		map("n", "gd", vim.lsp.buf.definition, { unpack(lsp_opts), desc = "goto the definition of symbol" })
		map("n", "yok", function()
			local enabled = not vim.lsp.inlay_hint.is_enabled({})
			vim.lsp.inlay_hint.enable(enabled)
			vim.notify("Inlay hints: " .. (enabled and " on" or "off"))
		end, { desc = "lsp: toggle inlay hints" })

		cmd("CodeLens", function()
			vim.lsp.codelens()
		end, { desc = "lsp: codelens enabled" })
		cmd("Format", function()
			vim.lsp.buf.format({ async = true, timeout_ms = 5000 })
		end, { desc = "lsp: format current file with LSP or formatter" })
	end,
})

-- keymaps
-- You can use the capture groups defined in `textobjects.scm`
map({ "x", "o" }, "af", function()
	return require("nvim-treesitter-textobjects.select").select_textobject("@function.outer")
end)
map({ "x", "o" }, "if", function()
	return require("nvim-treesitter-textobjects.select").select_textobject("@function.inner")
end)
map({ "x", "o" }, "ac", function()
	return require("nvim-treesitter-textobjects.select").select_textobject("@class.outer")
end)
map({ "x", "o" }, "ic", function()
	return require("nvim-treesitter-textobjects.select").select_textobject("@class.inner")
end)
-- You can also use captures from other query groups like `locals.scm`
map({ "x", "o" }, "as", function()
	return require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end)

map("n", "<leader>a", function()
	return require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner")
end)
map("n", "<leader>A", function()
	return require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.outer")
end)

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
map({ "n", "x", "o" }, ";", function()
	return require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next()
end)
map({ "n", "x", "o" }, ",", function()
	return require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous()
end)

-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
map({ "n", "x", "o" }, "f", function()
	return require("nvim-treesitter-textobjects.repeatable_move").builtin_f_expr()
end, { expr = true })
map({ "n", "x", "o" }, "F", function()
	return require("nvim-treesitter-textobjects.repeatable_move").builtin_F_expr()
end, { expr = true })
map({ "n", "x", "o" }, "t", function()
	return require("nvim-treesitter-textobjects.repeatable_move").builtin_t_expr()
end, { expr = true })
map({ "n", "x", "o" }, "T", function()
	return require("nvim-treesitter-textobjects.repeatable_move").builtin_T_expr()
end, { expr = true })
