local M = {}

--	keymaps:
--		located at keymaps.lua
--	completion:
--		builtin-completion.lua or completion.lua
--		both work relatively okay but only one can be enabled

function M.setup()
	M.packages()
	M.config()
end

function M.packages()
	vim.pack.add({
		{ src = "https://github.com/neovim/nvim-lspconfig" },
		{ src = "https://github.com/nvimtools/none-ls.nvim" },
		{ src = "https://github.com/gbprod/none-ls-shellcheck.nvim" },
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

function M.config()
	vim.lsp.config("*", {
		capabilities = {
			textDocument = {
				semanticTokens = {
					multilineTokenSupport = true,
				},
			},
		},
		root_markers = { ".git" },
	}) -- General config

	vim.lsp.inlay_hint.enable(false)
	vim.lsp.semantic_tokens.enable(true)
	vim.highlight.priorities.semantic_tokens = 95
	local lsp_dir = vim.fn.stdpath("config") .. "/lsp"
	local present_configs = M.collect_files(lsp_dir)
	vim.lsp.enable(present_configs)
	vim.lsp.enable({
		"emmet_language_server",
		"marksman",
	})

	vim.api.nvim_create_autocmd("LspProgress", {
		group = vim.api.nvim_create_augroup("alphakeks.lsp.progress", { clear = true }),
		callback = function()
			print(vim.lsp.status())
		end,
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

-- This can make `/lsp/init.lua` requirable
-- local config_path = vim.fn.stdpath("config")
-- package.path = package.path .. ";" .. config_path .. "/lsp/init.lua"
-- require("lsp")

vim.defer_fn(M.setup, 100)

return M
