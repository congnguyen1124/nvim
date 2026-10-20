local M = {}

local api = vim.api
local ns = api.nvim_create_namespace('CodeScrollbar')
local states = {}
local pending = {}
local enabled = true

local excluded_filetypes = {
  ['neo-tree'] = true,
  ['jetgit'] = true,
  ['help'] = true,
  ['startuptime'] = true,
  ['gitcommit'] = true,
}

local function define_highlights()
  api.nvim_set_hl(0, 'CodeScrollbarBackground', { fg = '#3b4261', bg = '#16161e' })
  api.nvim_set_hl(0, 'CodeScrollbarTrack', { fg = '#3b4261', bg = '#16161e' })
  api.nvim_set_hl(0, 'CodeScrollbarViewport', { fg = '#7aa2f7', bg = '#16161e' })
  api.nvim_set_hl(0, 'CodeScrollbarCursor', { fg = '#7dcfff', bg = '#16161e', bold = true })
  api.nvim_set_hl(0, 'CodeScrollbarError', { fg = '#f7768e', bg = '#16161e', bold = true })
  api.nvim_set_hl(0, 'CodeScrollbarWarning', { fg = '#e0af68', bg = '#16161e', bold = true })
  api.nvim_set_hl(0, 'CodeScrollbarHealthy', { fg = '#9ece6a', bg = '#16161e', bold = true })
  api.nvim_set_hl(0, 'CodeScrollbarHeader', { fg = '#c0caf5', bg = '#16161e' })
end

local function is_eligible(win)
  if not enabled or not api.nvim_win_is_valid(win) then
    return false
  end
  if api.nvim_win_get_config(win).relative ~= '' then
    return false
  end
  local buf = api.nvim_win_get_buf(win)
  if not api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then
    return false
  end
  if excluded_filetypes[vim.bo[buf].filetype] then
    return false
  end
  return api.nvim_win_get_width(win) >= 20 and api.nvim_win_get_height(win) >= 4
end

local function close_window(win)
  local state = states[win]
  if not state then
    return
  end
  for _, float in ipairs({ state.bar_win, state.header_win }) do
    if float and api.nvim_win_is_valid(float) then
      api.nvim_win_close(float, true)
    end
  end
  states[win] = nil
end

local function ensure_buffer(buf)
  if buf and api.nvim_buf_is_valid(buf) then
    return buf
  end
  buf = api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  return buf
end

local function ensure_float(current, buf, config)
  if current and api.nvim_win_is_valid(current) then
    api.nvim_win_set_config(current, config)
    return current
  end
  local win = api.nvim_open_win(buf, false, vim.tbl_extend('force', config, {
    focusable = false,
    noautocmd = true,
    style = 'minimal',
    zindex = 45,
  }))
  vim.wo[win].winblend = 0
  vim.wo[win].wrap = false
  vim.wo[win].winhl = 'Normal:CodeScrollbarBackground,NormalFloat:CodeScrollbarBackground'
  return win
end

local function severity_name(item)
  local severity = tostring(item.severity or ''):lower()
  local level = tonumber(item.level)
  if severity:find('error', 1, true) or level == 1 then
    return 'error'
  end
  if severity:find('warn', 1, true) or level == 2 then
    return 'warning'
  end
  return nil
end

local function diagnostics(buf)
  local ok_info, info = pcall(api.nvim_buf_get_var, buf, 'coc_diagnostic_info')
  local ok_map, items = pcall(api.nvim_buf_get_var, buf, 'coc_diagnostic_map')
  if ok_info then
    local result = {
      errors = tonumber(info.error) or 0,
      warnings = tonumber(info.warning) or 0,
      items = {},
    }
    if ok_map and type(items) == 'table' then
      for _, item in ipairs(items) do
        local severity = severity_name(item)
        if severity and tonumber(item.lnum) then
          table.insert(result.items, { line = tonumber(item.lnum), severity = severity })
        end
      end
    end
    return result
  end

  local result = { errors = 0, warnings = 0, items = {} }
  for _, diagnostic in ipairs(vim.diagnostic.get(buf)) do
    local severity
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      result.errors = result.errors + 1
      severity = 'error'
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      result.warnings = result.warnings + 1
      severity = 'warning'
    end
    if severity then
      table.insert(result.items, { line = diagnostic.lnum + 1, severity = severity })
    end
  end
  return result
end

local function window_lines(win)
  local lines = api.nvim_win_call(win, function()
    return { vim.fn.line('w0'), vim.fn.line('w$') }
  end)
  return lines[1], lines[2]
end

local function document_row(line, line_count, height)
  if height <= 1 or line_count <= 1 then
    return 1
  end
  local ratio = (math.max(1, math.min(line, line_count)) - 1) / (line_count - 1)
  return math.floor(ratio * (height - 1)) + 1
end

local function set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function render_header(state, data)
  local text
  if data.errors == 0 and data.warnings == 0 then
    text = '✓ No issues'
  else
    text = string.format('E %d  W %d', data.errors, data.warnings)
  end
  set_lines(state.header_buf, { text })
  api.nvim_buf_clear_namespace(state.header_buf, ns, 0, -1)
  if data.errors == 0 and data.warnings == 0 then
    api.nvim_buf_set_extmark(state.header_buf, ns, 0, 0, {
      end_col = #text,
      hl_group = 'CodeScrollbarHealthy',
    })
  else
    local error_end = #('E ' .. data.errors)
    api.nvim_buf_set_extmark(state.header_buf, ns, 0, 0, {
      end_col = error_end,
      hl_group = 'CodeScrollbarError',
    })
    api.nvim_buf_set_extmark(state.header_buf, ns, 0, error_end + 2, {
      end_col = #text,
      hl_group = 'CodeScrollbarWarning',
    })
  end
  return vim.fn.strdisplaywidth(text)
end

local function render_bar(state, win, buf, data, height)
  local line_count = math.max(1, api.nvim_buf_line_count(buf))
  local top, bottom = window_lines(win)
  local cursor = api.nvim_win_get_cursor(win)[1]
  local top_row = document_row(top, line_count, height)
  local bottom_row = document_row(bottom, line_count, height)
  local cursor_row = document_row(cursor, line_count, height)
  local diagnostic_rows = {}

  for _, item in ipairs(data.items) do
    local row = document_row(item.line, line_count, height)
    if item.severity == 'error' or diagnostic_rows[row] ~= 'error' then
      diagnostic_rows[row] = item.severity
    end
  end

  local lines = {}
  for row = 1, height do
    local diagnostic_char = diagnostic_rows[row] and '●' or ' '
    local viewport_char = row >= top_row and row <= bottom_row and '┃' or '│'
    if row == cursor_row then
      viewport_char = '◆'
    end
    lines[row] = diagnostic_char .. viewport_char
  end
  set_lines(state.bar_buf, lines)
  api.nvim_buf_clear_namespace(state.bar_buf, ns, 0, -1)

  for row = 1, height do
    local severity = diagnostic_rows[row]
    if severity then
      api.nvim_buf_set_extmark(state.bar_buf, ns, row - 1, 0, {
        end_col = 3,
        hl_group = severity == 'error' and 'CodeScrollbarError' or 'CodeScrollbarWarning',
      })
    end
    api.nvim_buf_set_extmark(state.bar_buf, ns, row - 1, severity and 3 or 1, {
      end_col = #lines[row],
      hl_group = row == cursor_row and 'CodeScrollbarCursor'
        or (row >= top_row and row <= bottom_row and 'CodeScrollbarViewport' or 'CodeScrollbarTrack'),
    })
  end
end

function M.render(win)
  win = win or api.nvim_get_current_win()
  if not is_eligible(win) then
    close_window(win)
    return
  end

  local buf = api.nvim_win_get_buf(win)
  local width = api.nvim_win_get_width(win)
  local height = api.nvim_win_get_height(win)
  local bar_height = math.max(1, height - 1)
  local state = states[win] or {}
  state.bar_buf = ensure_buffer(state.bar_buf)
  state.header_buf = ensure_buffer(state.header_buf)

  state.bar_win = ensure_float(state.bar_win, state.bar_buf, {
    relative = 'win',
    win = win,
    anchor = 'NE',
    row = 1,
    col = width,
    width = 2,
    height = bar_height,
  })
  state.header_win = ensure_float(state.header_win, state.header_buf, {
    relative = 'win',
    win = win,
    anchor = 'NE',
    row = 0,
    col = width,
    width = 11,
    height = 1,
  })
  states[win] = state

  local data = diagnostics(buf)
  local header_width = math.max(11, render_header(state, data))
  api.nvim_win_set_config(state.header_win, {
    relative = 'win',
    win = win,
    anchor = 'NE',
    row = 0,
    col = width,
    width = header_width,
    height = 1,
  })
  render_bar(state, win, buf, data, bar_height)
end

local function schedule(win)
  win = win or api.nvim_get_current_win()
  if pending[win] then
    return
  end
  pending[win] = true
  vim.schedule(function()
    pending[win] = nil
    if api.nvim_win_is_valid(win) then
      pcall(M.render, win)
    else
      close_window(win)
    end
  end)
end

function M.refresh_all()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    schedule(win)
  end
end

function M.toggle()
  enabled = not enabled
  if enabled then
    M.refresh_all()
    vim.notify('Code scrollbar enabled.')
  else
    for win in pairs(states) do
      close_window(win)
    end
    vim.notify('Code scrollbar disabled.')
  end
end

function M.setup()
  if vim.g.loaded_code_scrollbar then
    return
  end
  vim.g.loaded_code_scrollbar = true
  define_highlights()

  api.nvim_create_user_command('CodeScrollbarToggle', M.toggle, { desc = 'Toggle code scrollbar' })
  api.nvim_create_user_command('CodeScrollbarRefresh', M.refresh_all, { desc = 'Refresh code scrollbar' })
  vim.keymap.set('n', '<leader>sb', M.toggle, { silent = true, desc = 'Toggle code scrollbar' })

  local group = api.nvim_create_augroup('CodeScrollbar', { clear = true })
  api.nvim_create_autocmd('ColorScheme', { group = group, callback = define_highlights })
  api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'WinEnter', 'WinResized', 'VimResized' }, {
    group = group,
    callback = M.refresh_all,
  })
  api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'TextChanged', 'TextChangedI', 'WinScrolled' }, {
    group = group,
    callback = function() schedule(api.nvim_get_current_win()) end,
  })
  api.nvim_create_autocmd('DiagnosticChanged', {
    group = group,
    callback = M.refresh_all,
  })
  api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'CocDiagnosticChange',
    callback = M.refresh_all,
  })
  api.nvim_create_autocmd('WinClosed', {
    group = group,
    callback = function(event) close_window(tonumber(event.match)) end,
  })
  vim.schedule(M.refresh_all)
end

return M
