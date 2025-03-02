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

	-- H1:
	vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#FE8018", bold = true })
	vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#DD6C00", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#342B21" }) -- 10% blend of #FE8018 with #1E2122

	-- H2:
	vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = "#83A598", bold = true })
	vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#6B8480", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#282E2E" }) -- 10% blend of #83A598 with #1E2122

	-- H3:
	vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = "#FABD2F", bold = true })
	vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#C49B22", bold = true })
	vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#343123" }) -- 10% blend of #FABD2F with #1E2122

	-- Markdown highlight fixes
	vim.cmd([[
    highlight @markup.raw.block.markdown guibg=NONE ctermbg=NONE
]])
end

return M
