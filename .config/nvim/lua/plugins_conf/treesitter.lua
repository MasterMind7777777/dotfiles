local M = {}

M.setup = function()
	require("nvim-treesitter.configs").setup({
		-- List of languages to install
		ensure_installed = {
			"lua",
			"typescript",
			"javascript",
			"html",
			"css",
			"json",
			"markdown",
		},

		sync_install = false, -- Install languages synchronously (only applied to `ensure_installed`)
		ignore_install = {}, -- List of parsers to ignore installing

		auto_install = true, -- Ensure parsers are auto-installed

		-- Enable highlighting using Treesitter
		highlight = {
			enable = true, -- Enable Treesitter-based highlighting
			additional_vim_regex_highlighting = false, -- Disable Vim regex-based highlighting (redundant with Treesitter)
		},

		-- Enable Treesitter indentation
		indent = {
			enable = true, -- Enable Treesitter-based indentation
		},

		-- Enable incremental selection for better text selections
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "<M-i>", -- Initiates selection with C-w
				node_incremental = "<M-i>", -- Increment selection with C-w
				scope_incremental = "<M-s>", -- Increment scope with C-s
				node_decremental = "<M-o>", -- Decrement selection with C-e
			},
		},

		textobjects = {
			select = {
				enable = true,

				-- Automatically jump forward to textobj, similar to targets.vim
				lookahead = true,

				keymaps = {
					-- You can use the capture groups defined in textobjects.scm
					["af"] = "@function.outer",
					["if"] = "@function.inner",
					["ac"] = "@class.outer",
					-- You can optionally set descriptions to the mappings (used in the desc parameter of
					-- nvim_buf_set_keymap) which plugins like which-key display
					["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
					-- You can also use captures from other query groups like `locals.scm`
					["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
				},
			},
		},

		-- Enable context-aware folding
		folding = {
			enable = true,
			-- disable = { "yaml" }, -- Disables folding for specific filetypes (optional)
		},

		-- Enable Tree-sitter-based refactoring (e.g., renaming symbols, etc.)
		refactor = {
			highlight_definitions = { enable = true }, -- Highlight definitions of symbols
			highlight_current_scope = { enable = true }, -- Highlight the current scope
		},

		modules = {}, -- Add this line to fix the missing required fields
	})
end

return M
