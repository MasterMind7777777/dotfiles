local prompts = {
	-- Code related prompts
	Explain = "Please explain how the following code works.",
	Review = "Please review the following code and provide suggestions for improvement.",
	Tests = "Please explain how the selected code works, then generate unit tests for it.",
	Refactor = "Please refactor the following code to improve its clarity and readability.",
	FixCode = "Please fix the following code to make it work as intended.",
	FixError = "Please explain the error in the following text and provide a solution.",
	BetterNamings = "Please provide better names for the following variables and functions.",
	Documentation = "Please provide documentation for the following code.",
	SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
	SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
	-- Text related prompts
	Summarize = "Please summarize the following text.",
	Spelling = "Please correct any grammar and spelling errors in the following text.",
	Wording = "Please improve the grammar and wording of the following text.",
	Concise = "Please rewrite the following text to make it more concise.",
}

local M = {
	opts = {
		model = "claude-3.5-sonnet",
		question_header = "## User ",
		answer_header = "## Copilot ",
		error_header = "## Error ",
		prompts = prompts,
		auto_follow_cursor = false, -- Don't follow the cursor after getting response
		mappings = {
			-- Use tab for completion
			complete = {
				detail = "Use @<Tab> or /<Tab> for options.",
				insert = "<Tab>",
			},
			-- Close the chat
			close = {
				normal = "q",
				insert = "<C-c>",
			},
			-- Reset the chat buffer
			reset = {
				normal = "<C-x>",
				insert = "<C-x>",
			},
			-- Submit the prompt to Copilot
			submit_prompt = {
				normal = "<CR>",
				insert = "<C-CR>",
			},
			-- Accept the diff
			accept_diff = {
				normal = "<C-a>",
				insert = "<C-a>",
			},
			-- Yank the diff in the response to register
			yank_diff = {
				normal = "gmy",
			},
			-- Show the diff
			show_diff = {
				normal = "gmd",
			},
			-- Show the prompt
			show_info = {
				normal = "gmp",
			},
			-- Show the user selection
			show_context = {
				normal = "gms",
			},
			-- Show help
			show_help = {
				normal = "gmh",
			},
		},
	},
}

return M
