-- lua/context.lua
local ts_utils = require("nvim-treesitter.ts_utils")

-- Change this if you prefer a different location.
local context_file = os.getenv("HOME") .. "/Documents/context.md"

local M = {}

------------------------------------------------------------------------------
-- 1. CORE UTILITY: Append text to the context file
------------------------------------------------------------------------------
function M.append_to_context(text)
	local file = io.open(context_file, "a")
	if file then
		file:write(text .. "\n")
		file:close()
		print("Appended to context:", context_file)
	else
		print("Error: Unable to open file " .. context_file)
	end
end

------------------------------------------------------------------------------
-- 2. APPEND THE ENTIRE CURRENT FILE CONTENT
------------------------------------------------------------------------------
function M.append_current_file()
	local file_path = vim.api.nvim_buf_get_name(0)
	if file_path == "" then
		print("No file associated with the current buffer.")
		return
	end

	-- Dynamically detect the file's language via `vim.bo.filetype`
	local language = vim.bo.filetype or "plaintext"

	-- Read the entire file from disk
	local file = io.open(file_path, "r")
	if file then
		local content = file:read("*all")
		file:close()

		local formatted = string.format("### %s\n\n```%s\n%s\n```\n", file_path, language, content)
		M.append_to_context(formatted)
	else
		print("Error: Unable to open file " .. file_path)
	end
end

------------------------------------------------------------------------------
-- 3. APPEND A FUNCTION (TREESITTER-BASED)
--    This grabs the function node at or above the cursor using nvim-treesitter
------------------------------------------------------------------------------
function M.append_function_treesitter()
	local node = ts_utils.get_node_at_cursor()
	if not node then
		print("No Tree-sitter node found at cursor!")
		return
	end

	-- Ascend until we find a 'function'-like node (depending on language)
	while node do
		local t = node:type()
		-- You may add more matches (e.g., "method_definition", "func_literal")
		if t:match("function") or t == "method_definition" then
			break
		end
		node = node:parent()
	end

	if not node then
		print("No function node found at/above cursor!")
		return
	end

	local start_row, start_col, end_row, end_col = node:range()
	-- Retrieve all lines for that node range
	local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
	local text = table.concat(lines, "\n")

	local file_path = vim.api.nvim_buf_get_name(0)
	local language = vim.bo.filetype or "plaintext"

	local formatted = string.format("### Function from %s\n\n```%s\n%s\n```\n", file_path, language, text)
	M.append_to_context(formatted)
end

------------------------------------------------------------------------------
-- 4. APPEND A FUNCTION (LSP-BASED)
--    Tries to get the definition via LSP for the symbol under cursor
------------------------------------------------------------------------------
function M.append_function_lsp()
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
		if err or not result or vim.tbl_isempty(result) then
			print("No LSP definition found for symbol under cursor.")
			return
		end

		-- Some LSPs return an array of definitions; take the first
		local def = result[1]
		local uri = def.uri or def.targetUri
		local range = def.range or def.targetRange
		if not uri or not range then
			print("Invalid definition data from LSP!")
			return
		end

		local bufnr = vim.uri_to_bufnr(uri)
		if not vim.api.nvim_buf_is_loaded(bufnr) then
			vim.fn.bufload(bufnr)
		end

		local start_line = range["start"].line
		local end_line = range["end"].line
		local lines = vim.api.nvim_buf_get_lines(bufnr, start_line, end_line + 1, false)
		local text = table.concat(lines, "\n")

		local file_path = vim.api.nvim_buf_get_name(bufnr)
		local language = vim.bo[bufnr].filetype or "plaintext"

		local formatted = string.format("### LSP definition from %s\n\n```%s\n%s\n```\n", file_path, language, text)
		M.append_to_context(formatted)
	end)
end

------------------------------------------------------------------------------
-- 5. OPEN THE CONTEXT FILE IN A NEW BUFFER
------------------------------------------------------------------------------
function M.open_context()
	vim.cmd("edit " .. context_file)
end

------------------------------------------------------------------------------
-- 6. COPY THE ENTIRE CONTEXT FILE TO SYSTEM CLIPBOARD (+ register)
------------------------------------------------------------------------------
function M.copy_context()
	local file = io.open(context_file, "r")
	if file then
		local content = file:read("*all")
		file:close()
		vim.fn.setreg("+", content)
		print("Context copied to system clipboard (+ register).")
	else
		print("Error: Unable to open file " .. context_file)
	end
end

return M
