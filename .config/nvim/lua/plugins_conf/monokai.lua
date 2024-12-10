local M = {}

function M.setup()
	require("monokai-pro").setup({
		transparent_background = true,
		terminal_colors = true,
		devicons = true, -- highlight the icons of `nvim-web-devicons`
		filter = "pro", -- options: "classic", "machine", "octagon", "pro", "ristretto", "spectrum"
		styles = {
			comment = { italic = true },
			keyword = { italic = true }, -- any other keyword
			type = { italic = true }, -- (preferred) int, long, char, etc
			storageclass = { italic = true }, -- static, register, volatile, etc
			structure = { italic = true }, -- struct, union, enum, etc
			parameter = { italic = true }, -- parameter pass in function
			annotation = { italic = true },
			tag_attribute = { italic = true }, -- attribute of tag in reactjs
		},
		inc_search = "background", -- underline | background
		background_clear = {
			"toggleterm",
			"telescope",
			"renamer",
			"notify",
		}, -- options: "float_win", "toggleterm", "telescope", "which-key", etc.
		plugins = {
			bufferline = {
				underline_selected = false,
				underline_visible = false,
			},
			indent_blankline = {
				context_highlight = "default", -- default | pro
				context_start_underline = false,
			},
		},
	})

	vim.cmd([[colorscheme monokai-pro]])
	vim.cmd("set cursorline")

	-- Customize line numbers to match Monokai Pro style
	vim.cmd([[
    highlight LineNr guifg=#75715e guibg=NONE
    highlight CursorLineNr guifg=#f8f8f2 guibg=NONE
    highlight SignColumn guibg=NONE
  ]])

	vim.cmd([[
    highlight NormalFloat guibg=#1f2335 guifg=#ffffff
    highlight FloatBorder guibg=#1f2335 guifg=#ff79c6
]])

	vim.cmd([[
  highlight @markup.raw.block.markdown guibg=NONE ctermbg=NONE
]])
end

return M
