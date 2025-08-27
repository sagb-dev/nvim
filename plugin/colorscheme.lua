vim.pack.add({ "https://github.com//miikanissi/modus-themes.nvim" })
require("modus-themes").setup()
vim.cmd.colorscheme("modus")
vim.api.nvim_set_hl(0, "Visual", { reverse = true })
vim.opt.termguicolors = true
