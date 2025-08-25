vim.loader.enable()

local M = {}
local map = vim.keymap.set
local set = vim.opt
local opts = { silent = true }
local au = vim.api.nvim_create_autocmd

M.disabled_keys = { -- {{{
	"<Space>",
	"<Down>",
	"<Up>",
	"<Left>",
	"<Right>",
	"<Backspace>",
	"<Enter>",
	"<CR>",
} -- }}}

function M.colorscheme() -- {{{
	vim.pack.add({ "https://github.com//miikanissi/modus-themes.nvim" })
	require("modus-themes").setup()
	vim.cmd.colorscheme("modus")
	vim.api.nvim_set_hl(0, "Visual", { reverse = true })
	vim.opt.termguicolors = true
end -- }}}

function M.global_variables() -- {{{
	-- if some configs are missing here, check .editorconfig and .stylua.toml
	vim.g.var = "alpPrj"
	vim.g.python3_host_prog = os.getenv('ASDF_DATA_DIR') .. "/python"
	vim.g.mapleader = ";" -- vim.keycode('<Space>')
	vim.g.localmapleader = vim.g.mapleader
end -- }}}

function M.completion() -- {{{
	-- TODO: I still don't get how the builtin completion works in neovim
	-- https://gpanders.com/blog/whats-new-in-neovim-0-11/#breaking-changes
	--
	-- Quick intro to builtin completion:
	-- In insert mode, <C-x> changes to completion mode
	-- To navigate, <C-n> and <C-p>
	-- <C-x><C-f> file name
	-- <C-x><C-l> whole line copying
	-- <C-x><C-n> buffer words, but remapped to <C-x><C-b>
	-- <C-x><C-k> dictionary
	-- <C-x><C-t> thesaurus completion
	-- <C-x><C-o> omni completion, now defaults to LSP as a source since 0.11
	-- <C-x><C-u> user defined completion, don't know how its used

	vim.pack.add({
		{ src = "https://github.com/L3MON4D3/LuaSnip" },
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
	})
	vim.opt.autocomplete = true
	vim.opt.complete = "o,.,w,b,u"
	vim.opt.completeopt = { "fuzzy", "preview", "popup", "menuone", "noinsert", "noselect" }
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			require("luasnip.loaders.from_vscode").lazy_load()
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if client == nil then
				return
			end

			if client:supports_method("textDocument/completion") then
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
			end
		end,
	})

	vim.keymap.set("i", "<C-x><C-b>", "<C-x><C-n>", { noremap = true })
end -- }}}

function M.keymaps() -- {{{
	map("n", "j", function()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
	end, { expr = true, silent = true }) -- Move down, but use 'gj' if no count is given
	map("n", "k", function()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
	end, { expr = true, silent = true }) -- Move up, but use 'gk' if no count is given
	map("v", "J", ":m '>+1<cr>gv=gv", opts) -- Move line blacks of any visual selection around
	map("v", "K", ":m '<-2<cr>gv=gv", opts)
	map("n", "J", "mzJ`z", opts)
	map("v", ">", ">gv", opts) -- Keep the visual selection after using < or > motions
	map("v", "<", "<gv", opts)
	map("n", "//", "/<Up>", opts) -- Go to last searched term
	map("n", "<Tab>", vim.cmd.bnext)
	map("n", "<S-Tab>", vim.cmd.bprevious)
	map("n", "d<Tab>", vim.cmd.bdelete)
	map("n", "<Leader>w", function()
		set.wrap = not vim.o.wrap
	end)
	map("n", "n", "nzzzv", opts)
	map("n", "N", "Nzzzv", opts)
	map("n", "#", "*N", opts) -- Simplify search, tbh it doesn't make much sense to search up or down for me
	map("n", "*", "*N", opts)
	map("i", ",", ",<C-g>u", opts) -- add break-points to undolist
	map("i", ".", ".<C-g>u", opts)
	map("i", "!", "!<C-g>u", opts)
	map("i", "?", "?<C-g>u", opts)
	map("n", "<Leader>cd", function()
		vim.fn.chdir(vim.fn.expand("%:p:h"))
	end, { unpack(opts), desc = "Change directory to the current file's directory" })
	-- TODO: I need to check if this works
	-- map("v", "<Leader>p", '"_dP') -- Paste without overwriting the default register
	if not vim.o.clipboard == "unnamedplus" then
		map({ "n", "x", "o" }, "gy", '"+y', { unpack(opts), desc = "Copy to clipboard" })
		map({ "n", "x", "o" }, "gp", '"+p', { unpack(opts), desc = "Paste clipboard text" })
	end
	map({ "n", "x", "o" }, "<C-l>", function()
		set.hlsearch = not vim.o.hlsearch and true
	end, { unpack(opts), desc = "Extend the default <C-l> keybind to work as a toggle" })
end -- }}}

function M.keymaps_lsp() -- {{{
	au("LspAttach", {
		callback = function(args)
			local lsp_opts = {
				buffer = args.buf,
				silent = true,
			}

			local qf_opts = {
				buffer = args.buf,
				silent = true,
			}

			map("n", "gD", vim.lsp.buf.declaration, lsp_opts)
			map("n", "gd", vim.lsp.buf.definition, lsp_opts)
			map("n", "<CR>", vim.lsp.buf.signature_help, lsp_opts)
			map("n", "gI", vim.lsp.buf.implementation, lsp_opts)
			map("n", "gr", vim.lsp.buf.references, lsp_opts)
			map("n", "gl", vim.diagnostic.open_float, lsp_opts)
			map("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, { unpack(lsp_opts), desc = "Next diagnostic" })
			map("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, { unpack(lsp_opts), desc = "Prev diagnostic" })
			map("n", "<Leader>ih", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
			end, { unpack(lsp_opts), desc = "Toggle inlay hints" })
			map({ "n", "v" }, "<Leader>f", function()
				vim.lsp.buf.format({ timeout_ms = 5000 })
			end, { unpack(lsp_opts), desc = "LSP Formatter" })
			map("n", "<Leader>ca", vim.lsp.buf.code_action, lsp_opts)
			map("n", "ggd", vim.diagnostic.setqflist, { unpack(qf_opts), desc = "Global diagnostics to qf" })
			map("n", "gdl", vim.diagnostic.setloclist, { unpack(qf_opts), desc = "Buffer diagnostics to qf" })
		end,
	})

	au("FileType", {
		pattern = "qf",
		callback = function()
			map("n", "<CR>", "<CR>", { unpack(opts), desc = "Jump to file" })
		end,
	})
end -- }}}

function M.setup()
	M.colorscheme()
	M.global_variables()
	vim.iter(M.disabled_keys):map(function(opt)
		return map("n", opt, "<Nop>")
	end)
	-- M.completion() -- see plugin/completion.lua
	M.keymaps()
	M.keymaps_lsp()
end

return M.setup()