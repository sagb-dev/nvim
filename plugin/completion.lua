vim.defer_fn(function()
	vim.pack.add({
		{
			src = "https://github.com/saghen/blink.cmp",
			version = vim.version.range("1.*"),
		},
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
		{ src = "https://github.com/onsails/lspkind.nvim" },
	})

	require("lspkind").init()
	local opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "select_and_accept", "fallback" },
		},
		fuzzy = { implementation = "prefer_rust_with_warning" },
		completion = {
			menu = {
				draw = {
					components = {
						kind_icon = {
							text = function(item)
								local kind = require("lspkind").symbol_map[item.kind] or ""
								return kind .. ""
							end,
						},
					},
				},
				auto_show = false, -- I use ghost_text
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 500,
			},
			ghost_text = {
				enabled = true,
			},
		},
		sources = {
			-- default = { "codeium", "lazydev", "lsp", "path", "buffer" },
			default = { "lsp", "path", "buffer" },
			providers = {},
		},
	}
	require("blink.cmp").setup(opts)

	local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
	local blink_status_ok, blink = pcall(require, "blink.cmp")
	if blink_status_ok then
		local ext_capabilities = vim.tbl_deep_extend("force", {}, lsp_capabilities, blink.get_lsp_capabilities())
		-- Configure LSP servers using the new vim.lsp.config syntax
		-- Default configuration for all servers
		vim.lsp.config("*", { capabilities = ext_capabilities })
	end
end, 1500)
