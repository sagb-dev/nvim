local M = {}

function M.packages()
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/nvimtools/none-ls.nvim" },
		{ src = "https://github.com/gbprod/none-ls-shellcheck.nvim" },
		{ src = "https://github.com/nvim-lua/plenary.nvim" }, -- none-ls and telescope dependency
	})
end

function M.collect_files(dir_path)
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

function M.status()
	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup("lsp.progress", { clear = true }),
		callback = function()
			print(vim.lsp.status())
		end,
	})
end

function M.config()
	local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
	local configured_servers = M.collect_files(lsp_dir)
	vim.lsp.enable(configured_servers)
	vim.lsp.enable({
		"emmet_language_server",
		"marksman",
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

	vim.lsp.inlay_hint.enable(true)
	vim.lsp.semantic_tokens.enable()
	vim.hl.priorities.semantic_tokens = 99 -- I prefer semantic lsp hl instead of ts hl
	vim.lsp.inline_completion.enable(true)

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

-- This can make `/lsp/init.lua` requirable
-- local config_path = vim.fn.stdpath("config")
-- package.path = package.path .. ";" .. config_path .. "/lsp/init.lua"
-- require("lsp")

function M.setup()
	M.packages()
	M.config()
	-- M.status()
end

vim.defer_fn(M.setup, 100)
-- M.setup()

return M
