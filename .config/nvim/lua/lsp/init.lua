-- Mason setup (LSP installer)
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "ts_ls", "lua_ls", "rust_analyzer" },
})

-- Load specific LSP configurations
-- require("lsp.ts_ls")
require("lsp.typescript-tools")
require("lsp.lua_ls")

-- Load null-ls for tools integrations
require("lsp.null-ls")
