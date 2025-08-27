vim.g.mapleader = ";" -- vim.keycode('<Space>')
vim.g.localmapleader = vim.g.mapleader

local disable = {
	"<Space>",
	"<Down>",
	"<Up>",
	"<Left>",
	"<Right>",
	"<Backspace>",
	"<Enter>",
	"<CR>",
}

vim.iter(disable):map(function(opt)
	return vim.keymap.set("n", opt, "<Nop>")
end)

vim.keymap.set("n", "j", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
end, { expr = true, silent = true }) -- Move down, but use 'gj' if no count is given
vim.keymap.set("n", "k", function()
	return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
end, { expr = true, silent = true }) -- Move up, but use 'gk' if no count is given
vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv") -- Move line blacks of any visual selection around
vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("v", ">", ">gv") -- Keep the visual selection after using < or > motions
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("n", "//", "/<Up>") -- Go to last searched term
vim.keymap.set("n", "<Tab>", vim.cmd.bnext)
vim.keymap.set("n", "<S-Tab>", vim.cmd.bprevious)
vim.keymap.set("n", "d<Tab>", vim.cmd.bdelete)
vim.keymap.set("n", "<Leader>w", function()
	vim.opt.wrap = not vim.o.wrap
end)
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "#", "*N") -- Simplify search, tbh it doesn't make much sense to search up or down for me
vim.keymap.set("n", "*", "*N")
vim.keymap.set("i", ",", ",<C-g>u") -- add break-points to undolist
vim.keymap.set("i", ".", ".<C-g>u")
vim.keymap.set("i", "!", "!<C-g>u")
vim.keymap.set("i", "?", "?<C-g>u")
vim.keymap.set("n", "<Leader>cd", function()
	vim.fn.chdir(vim.fn.expand("%:p:h"))
end)
vim.keymap.set({ "n", "x", "o" }, "gy", '"+y') -- in case you use unnamedplus, to use the system clipboard
vim.keymap.set({ "n", "x", "o" }, "gp", '"+p')
vim.keymap.set({ "n", "x", "o" }, "<C-l>", function()
	vim.opt.hlsearch = not vim.o.hlsearch and true
end)

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local lsp_opts = {
			buffer = args.buf,
			silent = true,
		}

		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, lsp_opts)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, lsp_opts)
		vim.keymap.set("n", "<CR>", vim.lsp.buf.signature_help, lsp_opts)
		vim.keymap.set("n", "gI", vim.lsp.buf.implementation, lsp_opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, lsp_opts)
		vim.keymap.set("n", "gl", vim.diagnostic.open_float, lsp_opts)
		vim.keymap.set("n", "]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, { unpack(lsp_opts), desc = "Next diagnostic" })
		vim.keymap.set("n", "[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, { unpack(lsp_opts), desc = "Prev diagnostic" })
		vim.keymap.set("n", "<Leader>ih", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
		end, { unpack(lsp_opts), desc = "Toggle inlay hints" })
		vim.keymap.set({ "n", "v" }, "<Leader>f", function()
			vim.lsp.buf.format({ timeout_ms = 5000 })
		end, { unpack(lsp_opts), desc = "LSP Formatter" })
		vim.keymap.set("n", "<Leader>ca", vim.lsp.buf.code_action, lsp_opts)
		vim.keymap.set("n", "ggd", vim.diagnostic.setqflist)
		vim.keymap.set("n", "gdl", vim.diagnostic.setloclist)

		-- vim.keymap.set("i", "<C-CR>", function()
		-- 	if not vim.lsp.inline_completion.get() then
		-- 		return "<C-CR>"
		-- 	end
		-- end, {
		-- 	expr = true,
		-- 	replace_keycodes = true,
		-- 	desc = "Get the current inline completion",
		-- })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		vim.keymap.set("n", "<CR>", "<CR>")
	end,
})

vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end)
vim.keymap.set("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end)
vim.keymap.set("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end)
vim.keymap.set("n", "<leader>fh", function()
	require("telescope.builtin").help_tags()
end)
