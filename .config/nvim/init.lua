-- Load options and Lazy.nvim
require("options")
require("lazy-setup")
require("custom.context")
require("keymaps")
require("lsp")
require("custom.select_functions")

-- Set default colorscheme to our Lush theme
pcall(vim.cmd, "colorscheme mastermind")
