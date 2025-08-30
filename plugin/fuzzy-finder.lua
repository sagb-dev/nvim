local M = {}

function M.setup()
	M.packages()
	M.config()
end

function M.packages()
	vim.api.nvim_create_autocmd("PackChanged", {
		callback = function(ev)
			local spec = ev.data.spec
			if spec and spec.name == "fff.nvim" and ev.data.kind == "install" or ev.data.kind == "update" then
				local fff_path = vim.fn.stdpath("data") .. "/site/pack/core/opt/fff.nvim"
				vim.fn.jobstart({ "cargo", "build", "--release" }, {
					cwd = fff_path,
					on_exit = function(_, code)
						if code == 0 then
							vim.notify("Cargo build finished successfully in " .. fff_path, vim.log.levels.INFO)
						else
							vim.notify("Cargo build failed with exit code " .. code, vim.log.levels.ERROR)
						end
					end,
				})
			end
		end,
	})

	vim.pack.add({
		"https://github.com/nvim-tree/nvim-web-devicons",
		"https://github.com/nvim-telescope/telescope.nvim",
		"https://github.com/nvim-lua/plenary.nvim", -- none-ls and telescope dependency
		"https://github.com/dmtrKovalenko/fff.nvim",
	})
end

function M.config()
	require("telescope").setup({
		pickers = {
			find_files = {
				find_command = { "rg", "--ignore", "-L", "--hidden", "--files" },
			},
		},
	})

	require("fff").setup({
		lazy_sync = true,
		max_threads = tonumber(vim.fn.system("nproc")),
		max_results = 50,
		debug = {
			enabled = false, -- Set to true to show scores in the UI
			show_scores = false,
		},
		logging = {
			enabled = false,
		},
	})

	require("config.keymaps").fuzzy_finder()
end

M.setup()

return M
