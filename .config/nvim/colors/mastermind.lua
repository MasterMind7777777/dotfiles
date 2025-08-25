-- Colorscheme entrypoint so :colorscheme mastermind works.
-- This loads the Lush spec and applies it.

vim.g.colors_name = "mastermind"

local ok, lush = pcall(require, "lush")
if not ok then
  vim.notify("lush.nvim not found (required for colorscheme 'mastermind')", vim.log.levels.ERROR)
  return
end

local spec = require("lush_theme.mastermind")
lush(spec)

-- Link Treesitter captures and special markup to theme groups using core groups
-- Doing this here avoids requiring Lush's `sym` helper, which isn't exposed in
-- your installed lush version.
local link = function(name, target)
  pcall(vim.api.nvim_set_hl, 0, name, { link = target })
end

-- Core capture links
link("@variable",   "Identifier")
link("@function",   "Function")
link("@type",       "Type")
link("@keyword",    "Keyword")
link("@string",     "String")
link("@number",     "Number")
link("@boolean",    "Boolean")
link("@variable.builtin", "Builtin")
link("@constant.builtin", "Builtin")
link("@namespace.builtin", "Builtin")
link("@namespace",           "Builtin")

-- Differentiate params, properties/fields, and calls
link("@parameter",              "Parameter")
link("@variable.parameter",     "Parameter")
link("@field",                  "Field")
link("@property",               "Property")
link("@variable.member",        "Property")
link("@function.call",          "FunctionCall")
link("@function.method",        "Function")
link("@function.method.call",   "MethodCall")

-- Markdown heading links to your custom groups
link("@markup.heading.1.markdown", "RenderMarkdownH1")
link("@markup.heading.2.markdown", "RenderMarkdownH2")
link("@markup.heading.3.markdown", "RenderMarkdownH3")

-- LSP semantic token links (TypeScript/JavaScript etc.)
link("@lsp.type.namespace",             "Builtin")
link("@lsp.type.property",              "Property")
link("@lsp.type.method",                "MethodCall")
link("@lsp.type.function",              "FunctionCall")
link("@lsp.type.parameter",             "Parameter")
link("@lsp.type.variable",              "Identifier")

-- Prefer builtin coloring for default library symbols (TS/JS)
link("@lsp.typemod.namespace.defaultLibrary", "Builtin")
link("@lsp.typemod.variable.defaultLibrary",  "Builtin")
link("@lsp.typemod.property.defaultLibrary",  "Property")
link("@lsp.typemod.method.defaultLibrary",    "MethodCall")

-- No ad-hoc console.* regex overrides; Treesitter ecma queries cover method calls via
-- @function.method.call and @variable.builtin captures.
