local M = {}

M.setup = function()
	-- local highlight = {
	-- 	"IblIndent",
	-- 	"IblScope",
	-- }

	local hooks = require("ibl.hooks")
	-- create the highlight groups in the highlight setup hook, so they are reset
	-- every time the colorscheme changes
	hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
		vim.api.nvim_set_hl(0, "IblScope", { fg = "#A1D372" })
		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#727072" })
	end)

	require("ibl").setup()
end

return M
