return {
	-- this is for
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope", -- Lazy-load the plugin on the `Telescope` command
		config = function()
			require("plugins_conf.telescope_conf").setup() -- Calls the setup function from the module
		end,
	},

	-- Utility functions (required by many plugins)
	{
		"nvim-lua/plenary.nvim",
	},

	-- Required for filetype icons
	{ "nvim-tree/nvim-web-devicons" },

	-- Required for Navic (to show location in status line)
	{ "SmiteshP/nvim-navic" },

	-- Kitty Scrollback plugin
	{
		"mikesmithgh/kitty-scrollback.nvim",
		enabled = true,
		lazy = true,
		cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
		event = { "User KittyScrollbackLaunch" },
		config = function()
			require("kitty-scrollback").setup()
		end,
	},

	{
		"loctvl842/monokai-pro.nvim",
		config = function()
			require("plugins_conf.monokai").setup()
		end,
	},

	-- Lualine for statusline
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Oil.nvim for file management
	{
		"stevearc/oil.nvim",
		config = function()
			require("plugins_conf.oil").setup()
		end,
	},

	-- Comment plugin
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},

	-- Surround plugin
	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability
		config = function()
			require("nvim-surround").setup({})
		end,
	},

	-- Treesitter for syntax highlighting and more
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("plugins_conf.treesitter").setup() -- Calls the setup function from the module
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter",
		requires = "nvim-treesitter/nvim-treesitter",
	},

	-- LSP configuration
	{ "neovim/nvim-lspconfig" },

	-- LSP installer and utilities
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },

	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
	},

	{
		"aznhe21/actions-preview.nvim",
		config = function()
			vim.keymap.set({ "v", "n" }, "<leader>ca", require("actions-preview").code_actions)
		end,
	},

	{
		"mrcjkb/rustaceanvim",
		version = "^5", -- Recommended
		lazy = false, -- This plugin is already lazy
	},

	{
		"saecki/crates.nvim",
		tag = "stable",
		config = function()
			require("crates").setup()
		end,
	},

	-- None-ls for formatting and linting
	{ "nvimtools/none-ls.nvim" },

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip", -- Snippet engine
		},
	},

	-- Required for Copilot status line integration
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("plugins_conf.copilot").setup()
		end,
	},

	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
		},
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = require("plugins_conf.CopilotChat.opts").opts, -- opts from opts.lua
		keys = require("plugins_conf.CopilotChat.keys").keys, -- keys from keys.lua
		config = function(_, opts)
			require("plugins_conf.CopilotChat.config").config(_, opts) -- config from config.lua
		end,
	},

	-- In your lazy-setup.lua or init.lua
	{
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({
				"*", -- Highlight colors in all filetypes
			})
		end,
	},

	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true }, -- Optional
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
		config = function()
			require("plugins_conf.indent-blankline").setup()
		end,
	},

	{
		"tpope/vim-fugitive",
		cmd = "Git",
		keys = {
			{ "<Leader>gg", ":Git<CR>", desc = "Open Fugitive Git" },
		},
	},

	{
		"folke/trouble.nvim",
		opts = {}, -- for default options, refer to the configuration section for custom setup.
		cmd = "Trouble",
		keys = {
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
	},
}
