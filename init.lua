local M = {}

vim.loader.enable()

vim.g.mapleader = ";" -- vim.keycode('<Space>')
vim.g.localmapleader = vim.g.mapleader

function M.setup()
	M.colorscheme()
	M.options()
	M.file_manager()

	vim.schedule(M.diagnostics)
	vim.schedule(M.lsp)

	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			require("config.keymaps").lsp(args)
		end,
	})
	require("config.keymaps").general()
end

function M.colorscheme()
	vim.pack.add({ "https://github.com/miikanissi/modus-themes.nvim" })
	vim.cmd.colorscheme("modus")
end

function M.options()
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
	-- if you make use of `n` in cpsetions and virtual_lines you'll have to modify
	-- the format of the diagnostics displayed by virtual_lines
	-- vim.o.cpoptions:append("n")
	vim.o.showbreak = "↪ "
	vim.o.breakindent = true
	vim.o.clipboard = "unnamedplus"
	vim.o.colorcolumn = tostring(80)
	vim.o.conceallevel = 1
	vim.o.copyindent = true
	vim.opt.formatoptions = vim.opt.formatoptions + "r" + "c" + "q" + "j" - "t" - "a" - "o" - tostring(2)
	vim.o.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.o.hlsearch = true -- if true, clear with <C-l>
	vim.o.ignorecase = true
	vim.o.inccommand = "split"
	vim.o.incsearch = true
	vim.o.infercase = true
	vim.o.joinspaces = false
	vim.o.lazyredraw = false
	vim.o.linebreak = true
	vim.o.list = true
	vim.o.mouse = "a"
	vim.o.preserveindent = true
	vim.o.shiftround = true
	vim.o.showcmd = false
	vim.o.smartcase = true
	vim.o.smartindent = true
	vim.o.smarttab = true
	vim.o.smoothscroll = true
	-- vim.o.spelllang = "en,es"
	-- vim.o.spelloptions = "camel,noplainbuffer"
	-- vim.o.spellsuggest = "best," .. tostring(6)
	vim.o.splitbelow = true
	vim.o.splitright = true
	vim.o.startofline = true

	-- Default values, ignored in this config because of .editorconfig
	vim.o.tabstop = 4
	vim.o.shiftwidth = vim.o.tabstop

	vim.o.timeoutlen = 600
	vim.o.title = true
	vim.o.titlelen = 0
	vim.o.ttimeoutlen = 10
	vim.o.undofile = true
	vim.o.updatetime = 300
	vim.o.virtualedit = "all" -- all, block
	-- vim.o.winborder = "rounded"

	vim.o.number = true
	vim.o.relativenumber = true
	vim.o.numberwidth = 1
	vim.o.foldcolumn = "auto:" .. tostring(1)
	vim.o.signcolumn = "yes:" .. tostring(1)

	vim.o.swapfile = false
	vim.o.backup = true
	vim.o.backupcopy = "yes"

	-- no statusline, anywhere
	vim.api.nvim_set_hl(0, "StatusLine", { link = "WinSeparator" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { link = "WinSeparator" })
	vim.o.cmdheight = 0
	vim.o.laststatus = 0
	vim.o.statusline = "%{repeat('━',winwidth('.'))}"

	vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
		callback = function()
			vim.o.relativenumber = true
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
		callback = function()
			vim.o.relativenumber = false
		end,
	})

	vim.o.autowrite = true
	vim.o.autowriteall = true
	local skip_filetypes = {
		[""] = true,
		["*"] = true,
		help = true,
		netrw = true,
		vim = true,
	}

	local skip_buftypes = {
		acwrite = true, -- oil.nvim buffer
		oil = true,
	}

	vim.api.nvim_create_autocmd("FocusLost", {
		callback = function()
			if skip_buftypes[vim.bo.buftype] or skip_filetypes[vim.bo.filetype] then
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
			if skip_buftypes[vim.bo.buftype] or skip_filetypes[vim.bo.filetype] then
				return
			end
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

function M.diagnostics()
	vim.diagnostic.config({
		float = {
			focusable = true,
			style = "minimal",
			-- border = "rounded",
			source = false, -- Show source in diagnostic popup window
			header = "",
			prefix = "  ",
		},
		-- virtual_lines = {
		-- 	current_line = true,
		-- },
		virtual_text = true,
		signs = {
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.HINT] = " ",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
		underline = true,
		update_in_insert = false,
		severity_sort = true,
	})
end

function M.file_manager()
	-- NetRW
	vim.g.netrw_liststyle = 3
	vim.g.netrw_banner = 0
	vim.g.netrw_winsize = 20 -- I should improve this to be dynamic
	vim.g.netrw_browse_split = 4 -- open files in previous window
	vim.g.netrw_altv = 1

	vim.pack.add({
		"https://github.com/stevearc/oil.nvim",
		"https://github.com/nvim-mini/mini.nvim",
		"https://github.com/nvim-tree/nvim-web-devicons",
	})
	require("oil").setup({
		delete_to_trash = true,
		watch_for_changes = true,
		float = {
			max_height = 20,
			max_width = 60,
		},
		view_options = {
			show_hidden = true,
		},
	})
end

function M.lsp()
	vim.pack.add({
		"https://github.com/neovim/nvim-lspconfig",
		"https://github.com/nvimtools/none-ls.nvim",
		"https://github.com/gbprod/none-ls-shellcheck.nvim",
		"https://github.com/nvim-lua/plenary.nvim", -- none-ls and telescope dependency
	})

	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup("lsp.progress", { clear = true }),
		callback = function()
			print(vim.lsp.status())
		end,
	})

	vim.lsp.config("*", {
		capabilities = {
			textDocument = {
				semanticTokens = {
					multilineTokenSupport = true,
				},
			},
		},
		root_markers = { ".git" },
	})

	vim.lsp.document_color.enable()
	vim.lsp.inlay_hint.enable(true)
	vim.lsp.semantic_tokens.enable()
	vim.hl.priorities.semantic_tokens = 99 -- I prefer semantic lsp hl instead of ts hl
	vim.lsp.inline_completion.enable(true)

	local function collect_files(dir_path)
		local tbl = {}
		local files = vim.fn.glob(dir_path .. "/*.lua", false, true)
		vim.iter(files):map(function(file)
			local filename = vim.fn.fnamemodify(file, ":t:r")
			if filename == "init" then
				return
			end
			return table.insert(tbl, filename)
		end)
		return tbl
	end

	local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
	local configured_servers = collect_files(lsp_dir)
	vim.lsp.enable(configured_servers)
	vim.lsp.enable({
		"basedpyright",
		"emmet_language_server",
		"jdtls",
		"marksman",
		"nushell",
		"rust_analyzer",
		"svelte",
		"zls",
	})

	local null_ls = require("null-ls")
	null_ls.setup({
		sources = {
			null_ls.builtins.formatting.stylua,
			null_ls.builtins.code_actions.gitsigns,
			require("none-ls-shellcheck.diagnostics"),
			require("none-ls-shellcheck.code_actions"),
		},
	})
end

M.setup()

return M
