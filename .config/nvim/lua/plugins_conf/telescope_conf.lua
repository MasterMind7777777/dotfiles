-- File: ~/.config/nvim/lua/plugins/telescope_conf.lua
local M = {}

M.setup = function()
	require("telescope").setup({
		defaults = {
			mappings = {
				i = {
					["<C-j>"] = require("telescope.actions").move_selection_next,
					["<C-k>"] = require("telescope.actions").move_selection_previous,
				},
			},
		},
	})

	-- Keymaps for Telescope
	vim.keymap.set("n", "<leader>pf", ":Telescope find_files<CR>", { desc = "Find Files" })
	vim.keymap.set("n", "<leader>ps", ":Telescope live_grep<CR>", { desc = "Search String in Files" })
end

return M
