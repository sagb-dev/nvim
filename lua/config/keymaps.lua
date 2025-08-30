local M = {}

function M.setup()
	M.general()
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = M.lsp,
	})
end

function M.general()
	M.disable = {
		"<Space>",
		"<Down>",
		"<Up>",
		"<Left>",
		"<Right>",
		"<Backspace>",
		"<Enter>",
		"<CR>",
	}

	vim.iter(M.disable):map(function(opt)
		return vim.keymap.set("n", opt, "<Nop>")
	end)

	vim.keymap.set("v", "J", ":m '>+1<cr>gv=gv") -- Move line blacks of any visual selection around
	vim.keymap.set("v", "K", ":m '<-2<cr>gv=gv")
	vim.keymap.set("n", "J", "mzJ`z")
	vim.keymap.set("v", ">", ">gv") -- Keep the visual selection after using < or > motions
	vim.keymap.set("v", "<", "<gv")
	vim.keymap.set("n", "//", "/<Up>") -- Go to last searched term
	vim.keymap.set("n", "<Tab>", vim.cmd.bnext)
	vim.keymap.set("n", "<S-Tab>", vim.cmd.bprevious)
	vim.keymap.set("n", "d<Tab>", vim.cmd.bdelete)
	vim.keymap.set("n", "<leader>w", function()
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
	vim.keymap.set("n", "<leader>cd", function()
		vim.fn.chdir(vim.fn.expand("%:p:h"))
	end)
	vim.keymap.set({ "n", "x", "o" }, "gy", '"+y') -- in case you use unnamedplus, to use the system clipboard
	vim.keymap.set({ "n", "x", "o" }, "gp", '"+p')
	vim.keymap.set({ "n", "x", "o" }, "<C-l>", function()
		vim.opt.hlsearch = not vim.o.hlsearch and true
	end)

	vim.keymap.set("n", "gvp", "v`[`]")

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "qf",
		callback = function()
			vim.keymap.set("n", "<CR>", "<CR>")
		end,
	})

	vim.keymap.set("n", "<leader>hr", function()
		require("gitsigns").reset_hunk()
	end)

	vim.keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
end

function M.lsp(args)
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
	vim.keymap.set("n", "<leader>]d", function()
		vim.diagnostic.jump({ count = 1, float = true })
	end, { unpack(lsp_opts), desc = "Next diagnostic" })
	vim.keymap.set("n", "<leader>[d", function()
		vim.diagnostic.jump({ count = -1, float = true })
	end, { unpack(lsp_opts), desc = "Prev diagnostic" })
	vim.keymap.set("n", "<leader>ih", function()
		vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
	end, { unpack(lsp_opts), desc = "Toggle inlay hints" })
	vim.keymap.set({ "n", "v" }, "<leader>f", function()
		vim.lsp.buf.format({ timeout_ms = 5000 })
	end, { unpack(lsp_opts), desc = "LSP Formatter" })
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, lsp_opts)
	vim.keymap.set("n", "<leader>dQ", vim.diagnostic.setqflist)
	vim.keymap.set("n", "<leader>dQl", vim.diagnostic.setloclist)
	-- I need to test this mapping
	vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { silent = true })

	vim.keymap.set("i", "<C-CR>", function()
		if not vim.lsp.inline_completion.get() then
			return "<C-CR>"
		end
	end, {
		expr = true,
		replace_keycodes = true,
		desc = "Get the current inline completion",
	})
end

function M.fuzzy_finder()
	vim.keymap.set("n", "<leader>ff", require("fff").find_files)
	vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
	vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)
	vim.keymap.set("n", "<leader>fh", require("telescope.builtin").help_tags)
	vim.keymap.set("n", "<leader>hQ", function()
		require("gitsigns").setqflist("all")
	end)
end

function M.treesitter()
	local select = require("nvim-treesitter-textobjects.select")
	local move = require("nvim-treesitter-textobjects.move")
	local swap = require("nvim-treesitter-textobjects.swap")
	local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

	-- Text objects: select
	-- keymaps
	-- You can use the capture groups defined in `textobjects.scm`
	vim.keymap.set({ "x", "o" }, "af", function()
		select.select_textobject("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "if", function()
		select.select_textobject("@function.inner", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "ac", function()
		select.select_textobject("@class.outer", "textobjects")
	end)
	vim.keymap.set({ "x", "o" }, "ic", function()
		select.select_textobject("@class.inner", "textobjects")
	end)
	-- You can also use captures from other query groups like `locals.scm`
	vim.keymap.set({ "x", "o" }, "as", function()
		select.select_textobject("@local.scope", "locals")
	end)

	-- Text objects: swap
	-- keymaps
	vim.keymap.set("n", "<leader>a", function()
		swap.swap_next("@parameter.inner")
	end)
	vim.keymap.set("n", "<leader>A", function()
		swap.swap_previous("@parameter.outer")
	end)

	-- Text objects: move
	-- keymaps
	-- You can use the capture groups defined in `textobjects.scm`
	vim.keymap.set({ "n", "x", "o" }, "]m", function()
		move.goto_next_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]]", function()
		move.goto_next_start("@class.outer", "textobjects")
	end)
	-- You can also pass a list to group multiple queries.
	vim.keymap.set({ "n", "x", "o" }, "]o", function()
		move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
	end)
	-- You can also use captures from other query groups like `locals.scm` or `folds.scm`
	vim.keymap.set({ "n", "x", "o" }, "]s", function()
		move.goto_next_start("@local.scope", "locals")
	end)
	vim.keymap.set({ "n", "x", "o" }, "]z", function()
		move.goto_next_start("@fold", "folds")
	end)

	vim.keymap.set({ "n", "x", "o" }, "]M", function()
		move.goto_next_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "][", function()
		move.goto_next_end("@class.outer", "textobjects")
	end)

	vim.keymap.set({ "n", "x", "o" }, "[m", function()
		move.goto_previous_start("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[[", function()
		move.goto_previous_start("@class.outer", "textobjects")
	end)

	vim.keymap.set({ "n", "x", "o" }, "[M", function()
		move.goto_previous_end("@function.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[]", function()
		move.goto_previous_end("@class.outer", "textobjects")
	end)

	-- Go to either the start or the end, whichever is closer.
	-- Use if you want more granular movements
	vim.keymap.set({ "n", "x", "o" }, "]d", function()
		move.goto_next("@conditional.outer", "textobjects")
	end)
	vim.keymap.set({ "n", "x", "o" }, "[d", function()
		move.goto_previous("@conditional.outer", "textobjects")
	end)

	-- Repeat movement with ; and ,
	-- ensure ; goes forward and , goes backward regardless of the last direction
	vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
	vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

	-- vim way: ; goes to the direction you were moving.
	-- vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
	-- vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)

	-- Optionally, make builtin f, F, t, T also repeatable with ; and ,
	vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
	vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
end

return M
