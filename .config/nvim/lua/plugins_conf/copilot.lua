local M = {}

M.setup = function()
	-- Setup Copilot with proper suggestion options
	require("copilot").setup({
		suggestion = {
			enabled = true, -- Ensure suggestions are enabled
			auto_trigger = true, -- Automatically trigger suggestions when typing
			debounce = 75, -- Adjust debounce time for suggestions
		},
	})

	-- Bind Control + comma, period, slash for Copilot actions in insert mode
	vim.api.nvim_set_keymap(
		"i",
		"<C-,>",
		'<Cmd>lua require("copilot.suggestion").prev()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"i",
		"<C-.>",
		'<Cmd>lua require("copilot.suggestion").next()<CR>',
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"i",
		"<C-/>",
		'<Cmd>lua require("copilot.suggestion").accept()<CR>',
		{ noremap = true, silent = true }
	)

	-- Bind Control + Shift + / for accepting the whole word (new binding)
	vim.api.nvim_set_keymap(
		"i",
		"<C-S-/>",
		'<Cmd>lua require("copilot.suggestion").accept_word()<CR>',
		{ noremap = true, silent = true }
	)
end

return M
