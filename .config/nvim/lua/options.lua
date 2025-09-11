-- Enable line numbers
vim.opt.number = true -- Enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers for other lines

-- Use system clipboard
vim.opt.clipboard:append("unnamedplus")

-- Set the leader key to space
vim.g.mapleader = " "

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- Number of spaces per tab character
vim.opt.shiftwidth = 2 -- Number of spaces for autoindent
vim.opt.softtabstop = 2 -- Number of spaces a <Tab> counts for

vim.opt.termguicolors = true

-- rustaceanvim defaults: enable all features and clippy checks
-- Only override cmd if a local rust-analyzer exists at ~/.local/bin/rust-analyzer
do
  local ra_path = vim.fn.expand("~/.local/bin/rust-analyzer")
  local cmd = nil
  if vim.fn.filereadable(ra_path) == 1 then
    cmd = { ra_path }
  end

  vim.g.rustaceanvim = {
    server = {
      cmd = cmd, -- nil means use PATH / mason-managed analyzer
      default_settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          check = { command = "clippy" },
        },
      },
    },
  }
end
