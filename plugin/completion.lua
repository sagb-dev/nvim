local M = {}

function M.setup()
	M.snippets()
	-- M.builtin()
	M.blinkcmp()
end

function M.snippets()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local spec = ev.data.spec
			if spec and spec.name == "LuaSnip" and ev.data.kind == "install" or ev.data.kind == "update" then
				local luasnip_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/LuaSnip"
				vim.fn.jobstart({ "make", "install_jsregexp" }, {
					cwd = luasnip_path,
					on_exit = function(_, code)
						if code == 0 then
							vim.notify("LuaSnip make finished successfully in " .. luasnip_path, vim.log.levels.INFO)
						else
							vim.notify("LuaSnip make failed with exit code " .. code, vim.log.levels.ERROR)
						end
					end,
				})
			end
		end,
	})

	vim.pack.add({
		{ src = "https://github.com/L3MON4D3/LuaSnip" },
		{ src = "https://github.com/rafamadriz/friendly-snippets" },
	})

	require("luasnip").filetype_extend("ruby", { "rails" })

	require("luasnip.loaders.from_vscode").lazy_load()
	-- require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
end

function M.builtin()
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

	vim.opt.autocomplete = true
	vim.opt.complete = "o,.,w,b,u"
	vim.opt.completeopt:append({ "fuzzy", "preview", "popup", "menuone", "noinsert", "noselect" })
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
end

function M.blinkcmp()
	vim.pack.add({
		{
			src = "https://github.com/Saghen/blink.cmp",
			version = vim.version.range("^1"),
		},
	})

	local blink = require("blink.cmp")
	blink.setup({
		fuzzy = { implementation = "prefer_rust_with_warning" },
		cmdline = {
			keymap = {
				preset = "inherit",
			},
		},
		keymap = {
			preset = "default",
			["<C-p>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "select_next", "fallback" },
			["<CR>"] = { "select_and_accept", "fallback" },
			-- In insert mode, <C-y> and <C-e> are useful for copying lines above or below,
			-- blink.cmp doesn't recognize between insert or completion mode so it
			-- hijacks the keymaps in insert mode too
			["<C-y>"] = false,
			["<C-e>"] = false,
		},
		signature = { enabled = true },
		completion = {
			keyword = {
				range = "full",
			},
			trigger = {
				show_in_snippet = false,
				show_on_backspace = true,
				show_on_insert = true,
			},
			menu = {
				-- multiline ghost text when you select a menu item
				direction_priority = function()
					local ctx = require("blink.cmp").get_context()
					local item = require("blink.cmp").get_selected_item()
					if ctx == nil or item == nil then
						return { "s", "n" }
					end

					local item_text = item.textEdit ~= nil and item.textEdit.newText or item.insertText or item.label
					local is_multi_line = item_text:find("\n") ~= nil

					-- after showing the menu upwards, we want to maintain that direction
					-- until we re-open the menu, so store the context id in a global variable
					if is_multi_line or vim.g.blink_cmp_upwards_ctx_id == ctx.id then
						vim.g.blink_cmp_upwards_ctx_id = ctx.id
						return { "n", "s" }
					end
					return { "s", "n" }
				end,
				-- auto_show = false,
			},
			documentation = { auto_show = true },
			ghost_text = {
				enabled = true,
			},
		},
	})

	blink.opts_extend = { "sources.default" }

	local capabilities = {
		textDocument = {
			foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			},
		},
	}

	capabilities = blink.get_lsp_capabilities(capabilities)
end

M.setup()

return M
