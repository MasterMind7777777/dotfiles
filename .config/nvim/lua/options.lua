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
