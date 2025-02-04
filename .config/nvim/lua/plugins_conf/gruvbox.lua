local M = {}

function M.setup()
	require("gruvbox").setup({
		terminal_colors = true, -- Apply Gruvbox colors to terminal
		undercurl = true,
		underline = true,
		bold = true,
		italic = {
			strings = true,
			comments = true,
			operators = false,
			folds = true,
		},
		contrast = "hard", -- Options: "hard", "medium", "soft"
		inverse = true, -- Inverse highlight for search, diff, statuslines
		transparent_mode = true, -- Keep background transparent
	})

	-- Apply Gruvbox colorscheme
	vim.cmd("colorscheme gruvbox")

	-- Set custom Gruvbox highlights
	vim.cmd([[
    highlight LineNr guifg=#7c6f64 guibg=NONE
    highlight CursorLineNr guifg=#fabd2f guibg=NONE
    highlight SignColumn guibg=NONE
    highlight NormalFloat guibg=#1d2021 guifg=#ebdbb2
    highlight FloatBorder guibg=#1d2021 guifg=#fabd2f
    highlight Comment guifg=#928374 gui=italic
    highlight CursorLine guibg=#3c3836
  ]])

	-- Markdown highlight fixes
	vim.cmd([[
    highlight @markup.raw.block.markdown guibg=NONE ctermbg=NONE
]])
end

return M
