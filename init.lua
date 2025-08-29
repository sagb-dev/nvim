local M = {}

vim.loader.enable()
vim.g.mapleader = ";" -- vim.keycode('<Space>')
vim.g.localmapleader = vim.g.mapleader
local map = vim.keymap.set

function M.setup()
	M.general()
	M.colorscheme()
	M.file_managment()
	vim.schedule(M.keymaps)
end

function M.general()
	-- Command line abbreviations
	vim.cmd.cabbrev("Q q")
	vim.cmd.cabbrev("W w")
	vim.cmd.cabbrev("WQ wq")
	vim.cmd.cabbrev("Wqa wqa")

	vim.opt.fillchars:append({
		-- eob = "␗", -- End-of -Transmission-Block
		eob = " ",
		horiz = "━",
		horizup = "┻",
		horizdown = "┳",
		vert = "┃",
		vertleft = "┫",
		vertright = "┣",
		verthoriz = "╋",
		fold = " ",
		diff = "─",
		msgsep = "‾",
		foldsep = "│",
		foldopen = "▾",
		foldclose = "▸",
	})
	vim.opt.listchars:append({
		tab = "  ",
		-- tab = "▸ ",
		-- tab = "» ",
		-- tab = "!·",
		trail = "·",
		nbsp = "␣",
		-- eol = "↲",
	})
	vim.opt.whichwrap:append("<>[]hl~")
	vim.opt.backupdir:remove({ "." })
	vim.opt.cinkeys:remove(":")
	vim.opt.grepformat:append("%f:%l:%c:%m")
	-- if you make use of `n` in cpsetions and virtual_lines you'll have to modify
	-- the format of the diagnostics displayed by virtual_lines
	-- vim.opt.cpoptions:append("n")
	vim.opt.showbreak = "↪ "
	vim.opt.breakindent = true
	vim.opt.clipboard = "unnamedplus"
	vim.opt.colorcolumn = tostring(80)
	vim.opt.conceallevel = 1
	vim.opt.copyindent = true
	vim.opt.formatoptions = vim.opt.formatoptions + "r" + "c" + "q" + "j" - "t" - "a" - "o" - tostring(2)
	vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.opt.hlsearch = true -- if true, clear with <C-l>
	vim.opt.ignorecase = true
	vim.opt.inccommand = "split"
	vim.opt.incsearch = true
	vim.opt.infercase = true
	vim.opt.joinspaces = false
	vim.opt.lazyredraw = false
	vim.opt.linebreak = true
	vim.opt.list = true
	vim.opt.mouse = "a"
	vim.opt.preserveindent = true
	-- vim.opt.sidescrolloff = 9999
	-- vim.opt.sidescrolloff = 9999
	vim.opt.scrolloff = 3
	vim.opt.sidescrolloff = 3
	vim.opt.scrolljump = -90 -- scroll like emacs
	vim.opt.sessionoptions = {
		"blank",
		"buffers",
		"curdir",
		"folds",
		"globals",
		"help",
		"options",
		"resize",
		"tabpages",
		"terminal",
		"winpos",
		"winsize",
	}
	vim.opt.shiftround = true
	vim.opt.showcmd = false
	vim.opt.smartcase = true
	vim.opt.smartindent = true
	vim.opt.smarttab = true
	vim.opt.smoothscroll = true
	-- vim.opt.spelllang = "en,es"
	-- vim.opt.spelloptions = "camel,noplainbuffer"
	-- vim.opt.spellsuggest = "best," .. tostring(6)
	vim.opt.splitbelow = true
	vim.opt.splitright = true
	vim.opt.startofline = true

	-- Default values, ignored in this config because of .editorconfig
	vim.opt.tabstop = 4
	vim.opt.shiftwidth = vim.o.tabstop

	vim.opt.timeoutlen = 600
	vim.opt.title = true
	vim.opt.titlelen = 0
	vim.opt.ttimeoutlen = 10
	vim.opt.undofile = true
	vim.opt.updatetime = 300
	vim.opt.virtualedit = "block" -- all
	-- vim.opt.winborder = "rounded"

	vim.opt.number = true
	vim.opt.relativenumber = true
	vim.opt.numberwidth = 1
	vim.opt.foldcolumn = "auto:" .. tostring(6)
	vim.opt.signcolumn = "yes:" .. tostring(1)

	-- vim.opt.foldtext = "v:lua.MinimalFoldText()"
	--
	-- -- Function to create minimal fold text
	-- function _G.MinimalFoldText()
	-- 	local line = vim.fn.getline(vim.v.foldstart)
	-- 	local line_count = vim.v.foldend - vim.v.foldstart + 1
	--
	-- 	-- Clean up the line (remove leading whitespace and common fold markers)
	-- 	local cleaned_line = line:gsub("^%s*", ""):gsub("%d*", ""):gsub("{{", ""):gsub("}}", "")
	--
	-- 	-- Create a simple fold text with just the cleaned line and count
	-- 	return cleaned_line .. " [" .. line_count .. "]"
	-- end

	vim.opt.swapfile = false
	vim.opt.backup = true
	vim.opt.backupcopy = "yes"

	-- no statusline, anywhere
	vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeparator" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeparator" })
	vim.opt.cmdheight = 0
	vim.opt.laststatus = 0
	vim.opt.statusline = "%{repeat('━',winwidth('.'))}"

	vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
		callback = function()
			vim.opt.relativenumber = true
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
		callback = function()
			vim.opt.relativenumber = false
		end,
	})

	vim.opt.autowrite = true
	vim.opt.autowriteall = true
	vim.api.nvim_create_autocmd("FocusLost", {
		callback = function()
			local skip_filetypes = {
				[""] = true,
				["*"] = true,
				help = true,
				netrw = true,
				vim = true,
			}

			if skip_filetypes[vim.bo.filetype] then
				return
			end

			vim.cmd.write()
		end,
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost" }, {
		callback = function()
			local mark = vim.api.nvim_buf_get_mark(0, '"')
			if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
				if vim.o.filetype == "help" then
					return
				end
				vim.api.nvim_win_set_cursor(0, mark)
			end
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		callback = function(event)
			local dir = vim.fn.fnamemodify(event.match, ":p:h")
			if vim.fn.isdirectory(dir) == 0 then
				vim.fn.mkdir(dir, "p")
			end
		end,
	})

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePre", {
		callback = function()
			local save_cursor = vim.fn.getpos(".")
			vim.cmd([[%s/\s\+$//e]])
			vim.fn.setpos(".", save_cursor)
		end,
	})

	vim.api.nvim_create_autocmd("VimResized", { command = "wincmd =" })
	vim.api.nvim_create_autocmd("BufWinEnter", { command = "checktime" })
	vim.api.nvim_create_autocmd({ "BufWinLeave" }, { command = "silent! mkview" })
	vim.api.nvim_create_autocmd({ "BufWinEnter" }, { command = "silent! loadview" })

	require("vim._extui").enable({
		enable = true,
		msg = {
			target = "msg",
		},
	})
end

function M.colorscheme()
	vim.pack.add({ "https://github.com//miikanissi/modus-themes.nvim" })
	require("modus-themes").setup()
	vim.cmd.colorscheme("modus")
	vim.api.nvim_set_hl(0, "Visual", { reverse = true })
	vim.opt.termguicolors = true
end

function M.keymaps()
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
		return map("n", opt, "<Nop>")
	end)

	map("n", "j", function()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "j" or "gj"
	end, { expr = true, silent = true }) -- Move down, but use 'gj' if no count is given
	map("n", "k", function()
		return tonumber(vim.api.nvim_get_vvar("count")) > 0 and "k" or "gk"
	end, { expr = true, silent = true }) -- Move up, but use 'gk' if no count is given
	map("v", "J", ":m '>+1<cr>gv=gv") -- Move line blacks of any visual selection around
	map("v", "K", ":m '<-2<cr>gv=gv")
	map("n", "J", "mzJ`z")
	map("v", ">", ">gv") -- Keep the visual selection after using < or > motions
	map("v", "<", "<gv")
	map("n", "//", "/<Up>") -- Go to last searched term
	map("n", "<Tab>", vim.cmd.bnext)
	map("n", "<S-Tab>", vim.cmd.bprevious)
	map("n", "d<Tab>", vim.cmd.bdelete)
	map("n", "<Leader>w", function()
		vim.opt.wrap = not vim.o.wrap
	end)
	map("n", "n", "nzzzv")
	map("n", "N", "Nzzzv")
	map("n", "#", "*N") -- Simplify search, tbh it doesn't make much sense to search up or down for me
	map("n", "*", "*N")
	map("i", ",", ",<C-g>u") -- add break-points to undolist
	map("i", ".", ".<C-g>u")
	map("i", "!", "!<C-g>u")
	map("i", "?", "?<C-g>u")
	map("n", "<Leader>cd", function()
		vim.fn.chdir(vim.fn.expand("%:p:h"))
	end)
	map({ "n", "x", "o" }, "gy", '"+y') -- in case you use unnamedplus, to use the system clipboard
	map({ "n", "x", "o" }, "gp", '"+p')
	map({ "n", "x", "o" }, "<C-l>", function()
		vim.opt.hlsearch = not vim.o.hlsearch and true
	end)

	map("n", "gvp", "v`[`]")

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local lsp_opts = {
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
			map("n", "gdg", vim.diagnostic.setqflist)
			map("n", "gdl", vim.diagnostic.setloclist)

			-- map("i", "<C-CR>", function()
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
			map("n", "<CR>", "<CR>")
		end,
	})

	map("n", "<Leader>ff", require("fff").find_files)
	map("n", "<Leader>fm", vim.cmd.Oil)
	map("n", "<leader>fg", require("telescope.builtin").live_grep)
	map("n", "<leader>fb", require("telescope.builtin").buffers)
	map("n", "<leader>fh", require("telescope.builtin").help_tags)
	map("n", "<leader>hQ", function()
		require("gitsigns").setqflist("all")
	end)

end

function M.file_managment()
	vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
	require("oil").setup()

	-- NetRW
	vim.g.netrw_liststyle = 3
	vim.g.netrw_banner = 0
	vim.g.netrw_winsize = 20 -- I should improve this to be dynamic
	vim.g.netrw_browse_split = 4 -- open files in previous window
	vim.g.netrw_altv = 1
end

return M.setup()
