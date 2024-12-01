local common = require("lsp.common")

require("lspconfig").lua_ls.setup({
	on_attach = common.on_attach,
	capabilities = common.capabilities,
	on_init = function(client)
		-- Set up root directory
		local path = client.workspace_folders and client.workspace_folders[1].name
		if
			path
			and vim.fn.filereadable(path .. "/.luarc.json") == 0
			and vim.fn.filereadable(path .. "/.luarc.jsonc") == 0
		then
			client.config.settings.Lua.workspace.library = {
				vim.env.VIMRUNTIME,
				vim.fn.expand("$VIMRUNTIME/lua"),
				vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
				vim.api.nvim_get_runtime_file("", true),
			}
		end
	end,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
				path = vim.split(package.path, ";"),
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			telemetry = {
				enable = false,
			},
		},
	},
})
