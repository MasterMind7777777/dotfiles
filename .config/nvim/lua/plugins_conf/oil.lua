local M = {}

M.setup = function()
	require("oil").setup({
		default_file_explorer = true,
		columns = {
			"icon",
		},
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
			concealcursor = "nvic",
		},
		delete_to_trash = false,
		skip_confirm_for_simple_edits = false,
		prompt_save_on_select_new_entry = true,
		cleanup_delay_ms = 2000,
		lsp_file_methods = {
			enabled = true,
			timeout_ms = 1000,
			autosave_changes = true, -- changed
		},
		constrain_cursor = "editable",
		watch_for_changes = false,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
			["<C-h>"] = {
				"actions.select",
				opts = { horizontal = true },
				desc = "Open the entry in a horizontal split",
			},
			["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
			["<C-p>"] = "actions.preview",
			["<C-c>"] = "actions.close",
			["<C-l>"] = "actions.refresh",
			["-"] = "actions.parent",
			["`"] = "actions.cd",
			["~"] = { "actions.cd", opts = { scope = "tab" }, desc = ":tcd to the current oil directory", mode = "n" },
			["gs"] = "actions.change_sort",
			["gx"] = "actions.open_external",
			["g."] = "actions.toggle_hidden",
			["g\\"] = "actions.toggle_trash",
		},
		use_default_keymaps = true,
		view_options = {
			show_hidden = true,
			is_hidden_file = function(name, bufnr)
				return name:match("^%.") ~= nil
			end,
			is_always_hidden = function(name, bufnr)
				return false
			end,
			natural_order = "fast",
			case_insensitive = false,
			sort = {
				{ "type", "asc" },
				{ "name", "asc" },
			},
		},
		extra_scp_args = {},
		git = {
			add = function(path)
				return false
			end,
			mv = function(src_path, dest_path)
				return false
			end,
			rm = function(path)
				return false
			end,
		},
		float = {
			padding = 2,
			max_width = 0,
			max_height = 0,
			border = "rounded",
			win_options = {
				winblend = 10,
				winhl = "Normal:Normal,Float:Float",
			},
			get_win_title = nil,
			preview_split = "auto",
			override = function(conf)
				return conf
			end,
		},
		preview_win = {
			update_on_cursor_moved = true,
			preview_method = "fast_scratch",
			disable_preview = function(filename)
				return false
			end,
			win_options = {
				winblend = 10,
				winhl = "Normal:Normal,Float:Float",
			},
		},
		confirmation = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = 0.9,
			min_height = { 5, 0.1 },
			height = nil,
			border = "rounded",
			win_options = {
				winblend = 10,
				winhl = "Normal:Normal,Float:Float",
			},
		},
		progress = {
			max_width = 0.9,
			min_width = { 40, 0.4 },
			width = nil,
			max_height = { 10, 0.9 },
			min_height = { 5, 0.1 },
			height = nil,
			border = "rounded",
			minimized_border = "none",
			win_options = {
				winblend = 10,
				winhl = "Normal:Normal,Float:Float",
			},
		},
		ssh = {
			border = "rounded",
		},
		keymaps_help = {
			border = "rounded",
		},
	})
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
