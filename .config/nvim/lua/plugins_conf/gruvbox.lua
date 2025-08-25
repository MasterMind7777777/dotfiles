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

    -- Colorscheme application and overrides disabled in favor of mastermind
    -- (kept setup() so gruvbox remains available if you switch later)
end

return M
