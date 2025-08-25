-- Minimal Lush spec using pure hex colors.
-- Edit hexes below and run :Lushify on this file for live feedback.

local lush = require("lush")

-- Palette from waybar/cyberpank.css
local P = {
  -- Base tones
  bg        = "#0d0b1a", -- base
  bg_alt    = "#151028", -- mantle
  fg        = "#e6e6f0", -- text
  muted     = "#54497a", -- overlay0 (comments)
  subtle    = "#a8a4c5", -- subtext0 (line numbers etc)
  overlay1  = "#6b5da3",
  overlay2  = "#8276c0",

  -- Accents
  red       = "#ff3a3a", -- neon-red
  orange    = "#ff7b42", -- neon-orange
  yellow    = "#f8f32b", -- neon-yellow
  green     = "#3effb5", -- neon-green
  aqua      = "#00f0ff", -- neon-cyan
  blue      = "#28e0f7", -- neon-blue
  purple    = "#8c3cff", -- neon-purple
  magenta   = "#d12cff", -- neon-magenta
  pink      = "#ff2e88", -- neon-pink

  -- Surfaces
  surface0  = "#1e1a30",
  surface1  = "#2a2344",
  surface2  = "#3a305c",
}

-- Optional transparency: set bg = "NONE"
local transparent = true
if transparent then
  P.bg = "NONE"
  P.bg_alt = "NONE"
end

---@diagnostic disable: undefined-global
local theme = lush(function()
  return {
    -- Core editor UI
    Normal       { fg = P.fg, bg = P.bg },
    NormalFloat  { Normal, bg = P.surface0 },
    FloatBorder  { fg = P.yellow, bg = NormalFloat.bg },
    SignColumn   { bg = P.bg },
    LineNr       { fg = P.subtle, bg = P.bg },
    CursorLineNr { fg = P.yellow, bg = P.bg, gui = "bold" },
    CursorLine   { bg = P.surface0 },
    ColorColumn  { bg = P.surface1 },
    VertSplit    { fg = P.surface2, bg = P.bg },
    Directory    { fg = P.orange, gui = "bold" },
    Visual       { bg = P.surface2 },
    Search       { fg = P.bg, bg = P.yellow, gui = "bold" },
    IncSearch    { Search },
    MatchParen   { fg = P.orange, gui = "bold" },

    -- Diagnostics (LSP)
    DiagnosticError { fg = P.red },
    DiagnosticWarn  { fg = P.orange },
    DiagnosticInfo  { fg = P.blue },
    DiagnosticHint  { fg = P.aqua },

    -- Popup menu
    Pmenu       { fg = P.fg, bg = P.surface0 },
    PmenuSel    { fg = P.bg, bg = P.yellow },
    PmenuSbar   { bg = P.surface1 },
    PmenuThumb  { bg = P.surface2 },

    -- Statusline
    StatusLine   { fg = P.fg, bg = P.surface1 },
    StatusLineNC { fg = P.subtle, bg = P.surface0 },

    -- Syntax
    Comment     { fg = P.muted, gui = "italic" },
    Constant    { fg = P.yellow },
    String      { fg = P.green },
    Character   { String },
    Number      { fg = P.purple },
    Boolean     { fg = P.yellow },
    Float       { Number },
    Identifier  { fg = P.blue },
    Function    { fg = P.blue, gui = "bold" },
    FunctionCall{ fg = P.orange, gui = "bold" },
    MethodCall  { fg = P.pink,   gui = "bold" },
    MethodCallError { fg = P.red, gui = "bold" },
    Statement   { fg = P.magenta },
    Conditional { Statement },
    Repeat      { Statement },
    Label       { Statement },
    Operator    { fg = P.subtle },
    Keyword     { fg = P.magenta, gui = "bold" },
    Exception   { fg = P.red },
    PreProc     { fg = P.yellow },
    Include     { PreProc },
    Define      { PreProc },
    Macro       { PreProc },
    Type        { fg = P.aqua },
    StorageClass{ Type },
    Structure   { Type },
    Typedef     { Type },
    Special     { fg = P.orange },
    SpecialComment { fg = P.subtle, gui = "italic" },
    Delimiter   { fg = P.subtle },

    -- Treesitter captures are linked in colors/mastermind.lua

    -- Semantic accents to link from Treesitter
    Builtin  { fg = P.aqua,  gui = "bold" },
    Parameter { fg = P.pink },
    Property  { fg = P.yellow },
    Field     { fg = P.yellow },

    -- Plugin: indent-blankline (ibl)
    IblIndent { fg = P.surface2 },
    IblScope  { fg = P.overlay1 },

    -- Plugin: render-markdown headings (Cyberpunk neon vibes)
    RenderMarkdownH1       { fg = P.yellow, gui = "bold" },
    RenderMarkdownH1Bg     { bg = P.surface1 },

    RenderMarkdownH2       { fg = P.pink, gui = "bold" },
    RenderMarkdownH2Bg     { bg = P.surface1 },

    RenderMarkdownH3       { fg = P.blue, gui = "bold" },
    RenderMarkdownH3Bg     { bg = P.surface2 },

    -- Plugin: oil.nvim custom groups
    OilDir      { fg = P.orange, gui = "bold" },
    OilDirIcon  { fg = P.orange, gui = "bold" },
    OilSocket   { fg = P.fg,    gui = "italic" },
    OilLink     { fg = P.pink,  gui = "italic" },
    OilFile     { fg = P.fg },
    OilCreate   { fg = P.green, gui = "bold" },
    OilDelete   { fg = P.red,   gui = "bold" },
    OilMove     { fg = P.yellow,gui = "bold" },
    OilCopy     { fg = P.blue,  gui = "bold" },
    OilChange   { fg = P.yellow,gui = "bold" },
  }
end)

return theme
