local M = {}

local api = vim.api
local namespace = api.nvim_create_namespace('PythonProTokyoNight')

local palette = {
  background = '#1a1b26',
  background_dark = '#16161e',
  selection = '#283457',
  foreground = '#c0caf5',
  muted = '#565f89',
  blue = '#7aa2f7',
  cyan = '#7dcfff',
  green = '#9ece6a',
  orange = '#ff9e64',
  purple = '#bb9af7',
  red = '#f7768e',
  yellow = '#e0af68',
}

local groups = {
  Normal = { fg = palette.foreground, bg = palette.background },
  NormalNC = { fg = palette.foreground, bg = palette.background_dark },
  NormalFloat = { fg = palette.foreground, bg = palette.background_dark },
  SignColumn = { fg = palette.muted, bg = palette.background },
  FoldColumn = { fg = palette.muted, bg = palette.background },
  LineNr = { fg = palette.muted, bg = palette.background },
  CursorLine = { bg = '#20233a' },
  CursorLineNr = { fg = palette.yellow, bg = '#20233a', bold = true },
  ColorColumn = { bg = '#24283b' },
  Visual = { bg = palette.selection },
  WinSeparator = { fg = '#3b4261', bg = palette.background },
  Pmenu = { fg = palette.foreground, bg = palette.background_dark },
  PmenuSel = { fg = palette.background, bg = palette.blue, bold = true },
  Search = { fg = palette.background, bg = palette.yellow },
  IncSearch = { fg = palette.background, bg = palette.orange },

  pythonStatement = { fg = palette.purple, bold = true },
  pythonConditional = { fg = palette.purple },
  pythonRepeat = { fg = palette.purple },
  pythonOperator = { fg = palette.cyan },
  pythonException = { fg = palette.red },
  pythonInclude = { fg = palette.purple },
  pythonAsync = { fg = palette.purple, italic = true },
  pythonDecorator = { fg = palette.yellow },
  pythonDecoratorName = { fg = palette.yellow },
  pythonFunction = { fg = palette.blue },
  pythonComment = { fg = palette.muted, italic = true },
  pythonTodo = { fg = palette.background, bg = palette.yellow, bold = true },
  pythonString = { fg = palette.green },
  pythonRawString = { fg = palette.green },
  pythonQuotes = { fg = palette.green },
  pythonTripleQuotes = { fg = palette.green },
  pythonEscape = { fg = palette.cyan },
  pythonNumber = { fg = palette.orange },
  pythonBuiltin = { fg = palette.cyan },
  pythonAttribute = { fg = palette.cyan },
  pythonExceptions = { fg = palette.red },
  pythonSpaceError = { fg = palette.red, underline = true },
  PythonProClassDeclaration = { fg = palette.purple, bold = true },

  CocSemTypeClass = { fg = palette.purple, bold = true },
  CocSemTypeModClassDeclaration = { fg = palette.purple, bold = true },
  CocSemTypeModClassDefinition = { fg = palette.purple, bold = true },
  CocSemTypeFunction = { fg = palette.blue },
  CocSemTypeMethod = { fg = palette.blue },
  CocSemTypeParameter = { fg = palette.yellow },
  CocSemTypeVariable = { fg = palette.foreground },
  CocSemTypeProperty = { fg = palette.cyan },
  CocSemTypeDecorator = { fg = palette.yellow },
  CocSemTypeNamespace = { fg = palette.cyan },
  CocErrorHighlight = { fg = palette.red, undercurl = true, sp = palette.red },
  CocWarningHighlight = { fg = palette.yellow, undercurl = true, sp = palette.yellow },
  CocInfoHighlight = { fg = palette.blue, undercurl = true, sp = palette.blue },
  CocHintHighlight = { fg = palette.cyan, undercurl = true, sp = palette.cyan },
  DiagnosticError = { fg = palette.red },
  DiagnosticWarn = { fg = palette.yellow },
  DiagnosticInfo = { fg = palette.blue },
  DiagnosticHint = { fg = palette.cyan },
  PythonProVenv = { fg = palette.cyan, bg = palette.background_dark, bold = true },
  PythonProVenvMissing = { fg = palette.yellow, bg = palette.background_dark, bold = true },
}

function M.define()
  for name, spec in pairs(groups) do
    api.nvim_set_hl(namespace, name, spec)
  end
  -- These names are unique to this plugin and are also needed while a winbar
  -- is being evaluated before its window-local namespace becomes active.
  api.nvim_set_hl(0, 'PythonProVenv', groups.PythonProVenv)
  api.nvim_set_hl(0, 'PythonProVenvMissing', groups.PythonProVenvMissing)
end

function M.apply(win)
  win = win or api.nvim_get_current_win()
  if api.nvim_win_is_valid(win) then
    api.nvim_win_set_hl_ns(win, namespace)
  end
end

function M.clear(win)
  win = win or api.nvim_get_current_win()
  if api.nvim_win_is_valid(win) then
    api.nvim_win_set_hl_ns(win, 0)
  end
end

function M.setup_buffer(buf)
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  api.nvim_buf_call(buf, function()
    vim.cmd('silent! syntax clear PythonProClassDeclaration')
    -- Python's builtin syntax marks declaration names as pythonFunction.
    -- Nesting this match gives class-style identifiers their own bold group.
    vim.cmd([[syntax match PythonProClassDeclaration /\<[A-Z][A-Za-z0-9_]*\>/ containedin=pythonFunction]])
  end)
end

function M.setup()
  M.define()
  local group = api.nvim_create_augroup('PythonProTheme', { clear = true })
  api.nvim_create_autocmd('ColorScheme', {
    group = group,
    callback = M.define,
  })
  api.nvim_create_autocmd('Syntax', {
    group = group,
    pattern = 'python',
    callback = function(event)
      M.setup_buffer(event.buf)
    end,
  })
  api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function(event)
      local win = api.nvim_get_current_win()
      local buf = event.buf or api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == 'python' then
        M.apply(win)
      else
        M.clear(win)
      end
    end,
  })
end

return M
