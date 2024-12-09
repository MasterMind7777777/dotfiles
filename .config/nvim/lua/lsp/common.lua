local M = {}

-- Keybindings and common settings for all LSP servers
M.on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end
		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	-- nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
	nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")

	-- Show full diagnostic message in a floating window
	nmap("gl", function()
		-- Open a floating window with the diagnostics
		vim.diagnostic.open_float(nil, { focusable = true, border = "rounded" })
	end, "Show full diagnostic message")
end

-- Capabilities for LSP (nvim-cmp integration)
M.capabilities = require("cmp_nvim_lsp").default_capabilities()

return M
