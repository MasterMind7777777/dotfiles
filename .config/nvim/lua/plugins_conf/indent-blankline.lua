local M = {}

M.setup = function()
	local hooks = require("ibl.hooks")

	-- Theme now defines Ibl* highlights (see lua/lush_theme/mastermind.lua)
	-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
	-- 	vim.api.nvim_set_hl(0, "IblScope", { fg = "#fabd2f" })
	-- 	vim.api.nvim_set_hl(0, "IblIndent", { fg = "#504945" })
	-- end)

	-- Apply the configuration
	require("ibl").setup()
end

return M
