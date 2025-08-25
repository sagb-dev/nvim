vim.filetype.add({
	extension = {
		mdx = "markdown",
		conf = "toml",
	},
	filename = {
		[".npmignore"] = "ignore",
		["tsconfig.tsbuildinfo"] = "json",
		["Brewfile"] = "ruby",
		[".eslintrc.json"] = "jsonc",
		["config"] = "conf",
	},
	pattern = {
		["tsconfig*.json"] = "jsonc",
		[".*/%.vscode/.*%.json"] = "jsonc",
	},
})
