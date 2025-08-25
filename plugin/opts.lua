local set = vim.opt
local au = vim.api.nvim_create_autocmd
local ag = vim.api.nvim_create_augroup

-- Command line abbreviations
vim.cmd.cabbrev("Q q")
vim.cmd.cabbrev("W w")
vim.cmd.cabbrev("WQ wq")
vim.cmd.cabbrev("Wqa wqa")

set.fillchars:append({
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
set.listchars:append({
	tab = "▸ ",
	-- tab = "» ",
	-- tab = "!·",
	trail = "·",
	nbsp = "␣",
	-- eol = "↲",
})
set.whichwrap:append("<>[]hl~")
set.backupdir:remove({ "." })
set.cinkeys:remove(":")
set.grepformat:append("%f:%l:%c:%m")
-- if you make use of `n` in cpsetions and virtual_lines you'll have to modify
-- the format of the diagnostics displayed by virtual_lines
-- set.cpoptions:append("n")
set.showbreak = "↪ "
set.breakindent = true
set.clipboard = "unnamedplus"
set.colorcolumn = tostring(80)
set.conceallevel = 1
set.copyindent = true
set.formatoptions = set.formatoptions + "r" + "c" + "q" + "j" - "t" - "a" - "o" - tostring(2)
set.grepprg = "rg --vimgrep --no-heading --smart-case"
set.hlsearch = true -- if true, clear with <C-l>
set.ignorecase = true
set.inccommand = "split"
set.incsearch = true
set.infercase = true
set.joinspaces = false
set.lazyredraw = false
set.linebreak = true
set.list = true
set.mouse = "a"
set.preserveindent = true
set.scrolloff = 9999
set.sidescrolloff = 9999
-- set.scrolljump = -50 -- scroll like emacs
set.sessionoptions = {
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
set.shiftround = true
set.shiftwidth = vim.o.tabstop
set.showcmd = false
set.smartcase = true
set.smartindent = true
set.smarttab = true
set.smoothscroll = true
-- set.spelllang = "en,es"
-- set.spelloptions = "camel,noplainbuffer"
-- set.spellsuggest = "best," .. tostring(6)
set.splitbelow = true
set.splitright = true
set.startofline = true
set.synmaxcol = 150
-- set.tabstop = 4
set.timeoutlen = 600
set.title = true
set.titlelen = 0
set.ttimeoutlen = 10
set.undofile = true
set.updatetime = 300
set.virtualedit = "block" -- all
-- set.winborder = "rounded"
set.foldcolumn = "auto"
set.number = true
set.relativenumber = true
set.numberwidth = 1

set.swapfile = false
set.backup = true
set.backupcopy = "yes"

-- no statusline, anywhere
vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "Normal" })
set.cmdheight = 0
set.ruler = false
set.laststatus = 0
set.statusline = "%{repeat('─',winwidth('.'))}"

local dynamic_gutter_numbers = ag("DynamicGutterNumbers", { clear = false })

au({ "InsertLeave", "CmdlineLeave" }, {
	desc = "Dynamic gutter numbers, they change based on mode",
	group = dynamic_gutter_numbers,
	callback = function()
		set.relativenumber = true
	end,
})

au({ "InsertEnter", "CmdlineEnter" }, {
	desc = "Dynamic gutter numbers, they change based on mode",
	group = dynamic_gutter_numbers,
	callback = function()
		set.relativenumber = false
	end,
})

set.autowrite = true
set.autowriteall = true
local auto_write_unfocused = ag("AutoWriteUnfocused", {
	clear = false,
})
au("FocusLost", {
	desc = "Write to the file when you unfocus neovim",
	group = auto_write_unfocused,
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

-- NetRW
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 20 -- I should improve this to be dynamic
vim.g.netrw_browse_split = 4 -- open files in previous window
vim.g.netrw_altv = 1

au({ "BufEnter", "BufReadPost" }, {
	desc = "Remember cursor position",
	group = ag("RememberCursorPosition", {
		clear = false,
	}),
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, mark)
		end
	end,
})

au("BufWritePre", {
	desc = "Before writing a file, create necessary directories if missing",
	group = ag("EnsureDirectoryStructure", {
		clear = false,
	}),
	callback = function(event)
		local dir = vim.fn.fnamemodify(event.match, ":p:h")
		if vim.fn.isdirectory(dir) == 0 then
			vim.fn.mkdir(dir, "p")
		end
	end,
})

au("TextYankPost", {
	desc = "Visual feedback when yanking text",
	group = ag("YankFeedback", {
		clear = false,
	}),
	callback = function()
		vim.highlight.on_yank()
	end,
})

au("CmdlineChanged", {
	callback = function()
		set.cmdwinheight = vim.fn.system("tput lines") / 2
	end,
})

au("BufWritePre", {
	desc = "Remove trailing whitespace",
	callback = function()
		local save_cursor = vim.fn.getpos(".")
		vim.cmd([[%s/\s\+$//e]])
		vim.fn.setpos(".", save_cursor)
	end,
})

au("VimResized", { command = "wincmd =", desc = "Auto-resize splits" })
au("BufWinEnter", { command = "checktime" })
au({ "BufWinLeave" }, { command = "silent! mkview" })
au({ "BufWinEnter" }, { command = "silent! loadview" })

require("vim._extui").enable({
	enable = true,
	msg = {
		target = "cmd",
		timeout = 3000,
	},
}) -- experimental I guess