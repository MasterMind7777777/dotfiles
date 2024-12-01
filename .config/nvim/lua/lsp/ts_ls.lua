local common = require("lsp.common")

require("lspconfig").ts_ls.setup({
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	settings = {
		javascript = {
			format = { enabled = false }, -- Disable built-in formatting
		},
		typescript = {
			format = { enabled = false },
		},
	},
})
