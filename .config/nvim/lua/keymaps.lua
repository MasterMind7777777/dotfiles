-- Map `-` to open oil.nvim
vim.keymap.set("n", "-", function()
	require("oil").open()
end, { desc = "Open parent directory with oil.nvim" })

-- Comment out a line or block with <leader>co
vim.keymap.set("n", "<leader>co", function()
	require("Comment.api").toggle.linewise.current()
end, { desc = "Comment out line" })

vim.keymap.set(
	"v",
	"<leader>co",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "Comment out selection" }
)

-- Yank the entire buffer with `yy` without moving the cursor
vim.keymap.set("n", "<leader>yy", ":%y<CR>", { desc = "Yank entire buffer without moving cursor" })

-- Replace the entire buffer with the content of the clipboard
vim.keymap.set("n", "<leader>dp", "ggVGp", { desc = "Replace entire buffer with clipboard" })

-- Keymaps for Telescope
vim.keymap.set("n", "<leader>pf", ":Telescope find_files<CR>", { desc = "Find Files" })
vim.keymap.set("n", "<leader>ps", ":Telescope live_grep<CR>", { desc = "Search String in Files" })

-- Create a custom command to source init.lua
vim.api.nvim_create_user_command("SourceInit", function()
	-- Source the init.lua file
	vim.cmd("source ~/.config/nvim/init.lua")
end, {})

-- Remap `]q` to go to the next quickfix item
vim.keymap.set("n", "]q", ":cnext<CR>zz", { desc = "Next quickfix item" })

-- Remap `[q` to go to the previous quickfix item
vim.keymap.set("n", "[q", ":cprev<CR>zz", { desc = "Previous quickfix item" })

-- Restart LSP with <leader>lr
vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>", { desc = "Restart LSP" })

-- Paragraph selection without empty lines
vim.keymap.set("v", "{", function()
	vim.cmd("normal! {")
	if vim.fn.line(".") ~= 1 then
		vim.cmd("normal! j")
	end
end, { desc = "Move to previous paragraph without empty line" })

vim.keymap.set("v", "}", function()
	vim.cmd("normal! }")
	if vim.fn.line(".") ~= vim.fn.line("$") then
		vim.cmd("normal! k")
	end
end, { desc = "Move to next paragraph without empty line" })

vim.keymap.set("n", "<Leader>fs", ":w<CR>", { noremap = true, silent = true })
