local M = {}

M.setup = function()
	local hooks = require("ibl.hooks")

	-- Register Gruvbox colors
	hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
		vim.api.nvim_set_hl(0, "IblScope", { fg = "#fabd2f" }) -- Gruvbox yellow
		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#504945" }) -- Gruvbox dark gray
	end)

	-- Apply the configuration
	require("ibl").setup()
end

return M
