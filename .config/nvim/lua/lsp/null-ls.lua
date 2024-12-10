local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.formatting.prettier, -- Prettier for JS/TS
		null_ls.builtins.formatting.stylua, -- Stylua for Lua
		null_ls.builtins.formatting.dxfmt, -- dxfmt for Rust
	},
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			-- Create an autocommand to format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end
	end,
})
