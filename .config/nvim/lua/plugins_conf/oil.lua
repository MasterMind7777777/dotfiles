local M = {}

M.setup = function()
	-- Configure Oil.nvim settings
	vim.g.oil_setup = {
		buf_options = {
			buflisted = false,
			bufhidden = "hide",
		},
		win_options = {
			wrap = false,
			signcolumn = "no",
			cursorcolumn = false,
			foldcolumn = "0",
			spell = false,
			list = false,
			conceallevel = 3,
			concealcursor = "nvc",
		},
		delete_to_trash = false,
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		cleanup_delay_ms = 2000,
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = true,
		},
		constrain_cursor = "editable",
		watch_for_changes = false,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
		},
	}

	-- Now, just call setup without arguments
	require("oil").setup()
	vim.cmd([[
" Oil highlights with Gruvbox color palette

highlight OilDir guifg=#fabd2f guibg=NONE gui=bold           " Directories in an oil buffer (Gruvbox Yellow)
highlight OilDirIcon guifg=#fabd2f guibg=NONE gui=bold       " Icon for directories (Gruvbox Yellow)
highlight OilSocket guifg=#ebdbb2 guibg=NONE gui=italic      " Socket files in an oil buffer (Gruvbox Light)
highlight OilLink guifg=#83a598 guibg=NONE gui=italic       " Soft links in an oil buffer (Gruvbox Aqua)
highlight OilFile guifg=#ebdbb2 guibg=NONE gui=NONE         " Normal files in an oil buffer (Gruvbox Light)
highlight OilCreate guifg=#b8bb26 guibg=NONE gui=bold       " Create action in the oil preview window (Gruvbox Green)
highlight OilDelete guifg=#fb4934 guibg=NONE gui=bold       " Delete action in the oil preview window (Gruvbox Red)
highlight OilMove guifg=#fabd2f guibg=NONE gui=bold         " Move action in the oil preview window (Gruvbox Yellow)
highlight OilCopy guifg=#83a598 guibg=NONE gui=bold         " Copy action in the oil preview window (Gruvbox Aqua)
highlight OilChange guifg=#d3869b guibg=NONE gui=bold       " Change action in the oil preview window (Gruvbox Purple)
  ]])
end

return M
