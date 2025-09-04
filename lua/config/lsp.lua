local M = {}

function M.setup()
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

	vim.lsp.document_color.enable()
	vim.lsp.semantic_tokens.enable()
	vim.hl.priorities.semantic_tokens = 99 -- I prefer semantic lsp hl instead of ts hl
	vim.lsp.inline_completion.enable(true)

	vim.lsp.enable({
		"basedpyright", -- python
		"emmet_language_server", -- js, react, etc
		"emmylua_ls",
		"jdtls", -- java
		"marksman", -- markdown
		"nushell", -- nushell
		"ocamllsp", -- ocaml
		"ruff", -- python
		"rust_analyzer", -- rust
		"svelte", -- svelte
		"zls", -- zig
		-- "lua_ls",
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

return M
