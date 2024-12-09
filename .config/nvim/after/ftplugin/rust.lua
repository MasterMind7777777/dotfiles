-- Get the current buffer number for buffer-specific keybindings
local bufnr = vim.api.nvim_get_current_buf()

-- Function to simplify keybinding creation
local function nmap(keys, func, desc)
	vim.keymap.set("n", keys, func, { buffer = bufnr, silent = true, desc = desc })
end

-- Keybindings for Rust (merged with your preferences)
nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
nmap("<leader>ca", function()
	vim.cmd.RustLsp("codeAction") -- Rust-specific code actions (grouped)
end, "[C]ode [A]ction (Rust LSP)")

nmap("K", function()
	vim.cmd.RustLsp({ "hover", "actions" }) -- Rust-specific hover actions
end, "Hover Documentation (Rust LSP)")

nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
nmap("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
-- Keybinding for explaining the current error
nmap("gh", function()
	vim.cmd.RustLsp({ "explainError", "current" })
end, "[G]et [H]elp (Explain Current Error)")

-- Show full diagnostic message in a floating window
nmap("gl", function()
	vim.diagnostic.open_float(nil, { focusable = true, border = "rounded" })
end, "Show full diagnostic message")

-- Go to type definition
nmap("gT", vim.lsp.buf.type_definition, "[G]oto [T]ype definition")

-- Show diagnostics in the current line
nmap("<leader>e", vim.diagnostic.open_float, "Show Diagnostics")

-- Navigate diagnostics
nmap("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
nmap("]d", vim.diagnostic.goto_next, "Next Diagnostic")
