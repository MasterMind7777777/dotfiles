-- Select function using LSP
function select_function_lsp()
	-- Request the document symbol from LSP to get the function range
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/selectionRange", params, function(_, _, result)
		if result and #result > 0 then
			-- Select the range of the function from the result
			local range = result[1].range
			-- Move cursor to the start of the selection
			vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
			vim.cmd("normal! v") -- Start visual mode
			-- Move cursor to the end of the selection
			vim.api.nvim_win_set_cursor(0, { range["end"].line + 1, range["end"].character })
		else
			print("No function range found via LSP.")
		end
	end)
end

-- Map the function to a key (example: vaf to select around function)
vim.api.nvim_set_keymap("n", "vaf", [[:lua select_function_lsp()<CR>]], { noremap = true, silent = true })
