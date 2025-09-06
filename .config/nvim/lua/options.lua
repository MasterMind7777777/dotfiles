-- Enable line numbers
vim.opt.number = true -- Enable absolute line numbers for the current line
vim.opt.relativenumber = true -- Enable relative line numbers for other lines

-- Use system clipboard
vim.opt.clipboard:append("unnamedplus")

-- Set the leader key to space
vim.g.mapleader = " "

vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.tabstop = 2 -- Number of spaces per tab character
vim.opt.shiftwidth = 2 -- Number of spaces for autoindent
vim.opt.softtabstop = 2 -- Number of spaces a <Tab> counts for

vim.opt.termguicolors = true

-- TEMPORARY FIXES UNTIL THE FOLLOWING PULL REQUESTS ARE MERGED:
local original_schedule = vim.schedule
vim.schedule = function(callback)
	original_schedule(function()
		local ok, err = pcall(callback)
		if not ok and string.match(err, "id: expected number, got string") then
			print("Ignored vim.schedule error: id: expected number, got string")
		elseif not ok then
			error(err) -- Re-raise unrelated errors
		end
	end)
end

-- Intercept and validate LSP client requests
local lsp = vim.lsp
local original_request = lsp.client and lsp.client.request

if original_request then
	lsp.client.request = function(method, params, callback, bufnr)
		-- Validate and log potential issues
		if params and type(params.id) == "string" then
			print("Suppressed invalid LSP request with string id:", params.id)
			return nil -- Suppress invalid request
		end

		-- Forward valid requests
		return original_request(method, params, callback, bufnr)
	end
end

-- Intercept `_process_request` to handle invalid ids
local original_process_request = lsp.client and lsp.client._process_request

if original_process_request then
	lsp.client._process_request = function(client, id, req_type, ...)
		-- Suppress invalid id types
		if type(id) ~= "number" then
			print("Suppressed invalid LSP request id:", id)
			return nil -- Suppress the invalid request
		end

		-- Forward valid requests
		return original_process_request(client, id, req_type, ...)
	end
end

-- TEMPORARY FIXES UNTIL THE FOLLOWING PULL REQUESTS ARE MERGED:

-- Use the smart wrapper (Option A)
vim.g.rustaceanvim = {
  server = {
    cmd = { vim.fn.expand("~/.local/bin/rust-analyzer") },
    default_settings = {
      ["rust-analyzer"] = {
        cargo = { allFeatures = true },
        check = { command = "clippy" },
      },
    },
  },
}
