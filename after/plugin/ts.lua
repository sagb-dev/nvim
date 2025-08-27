local M = {}

function M.packages()
	vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" } })
end

function M.extras()
	vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" } })
	require("treesitter-context").setup()
end

function M.config()
	require("nvim-treesitter.config").setup({
		ensure_installed = { "all" },
		sync_install = true,
		auto_install = true,
		ignore_install = {},
		indent = { enable = true },
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
			-- disable ts in big files
			disable = function(_, buf) -- _ is lang
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then
					return true
				end
			end,
		},
	})

	vim.api.nvim_create_autocmd("PackChanged", {
		desc = "Update treesitter parsers with every plugin update",
		callback = function(ev)
			local spec = ev.data.spec
			if spec and spec.name == "nvim-treesitter" and ev.data.kind == "update" then
				vim.schedule(require("nvim-treesitter").update)
			end
		end,
	})

	-- ts is enabled by default in neovim, but "nvim-treesitter" doesn't
	-- really work with any kind of lazy deferred loading, the commands like
	-- :TSInstall or :TSUpdate don't appear at all, so we force the plugin
	-- to load with the following command
	vim.cmd.packadd("nvim-treesitter")
end

function M.setup()
	M.packages()
	M.config()
	M.extras()
end

vim.defer_fn(M.setup, 1000)
-- M.setup()

return M
