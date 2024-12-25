local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- Define a custom source for rustfmt
local rustfmt = {
	name = "rustfmt",
	method = null_ls.methods.FORMATTING,
	filetypes = { "rust" },
	generator = helpers.formatter_factory({
		command = "rustfmt",
		args = { "--emit=stdout", "--edition=2021" },
		to_stdin = true,
	}),
}

null_ls.setup({
	sources = {
		-- Stylua for Lua
		null_ls.builtins.formatting.stylua,

		null_ls.builtins.formatting.prettier,

		rustfmt,
	},
	on_attach = function(client, bufnr)
		if client.server_capabilities.documentFormattingProvider then
			-- Clear existing autocommands
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			-- Create the autocommand
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr, async = false })
				end,
			})
		end
	end,
})
