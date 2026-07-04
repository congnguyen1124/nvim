-- jetgit/signs.lua - JetBrains-style gutter marks, hunk navigation,
-- hunk preview and line rollback (like IDE "Rollback Lines").
local util = require('jetgit.util')

local M = {}

local api = vim.api
local fn = vim.fn

local diff_fn = (vim.text and vim.text.diff) or vim.diff

-- cache[buf] = { root, rel, tracked, index_lines, hunks }
local cache = {}
local pending = {}

local MAX_LINES = 50000

local function define_highlights()
  local set = function(name, opts)
    opts.default = true
    api.nvim_set_hl(0, name, opts)
  end
  -- IntelliJ-ish gutter colors: green = added, blue = modified, red = deleted
  set('JetGitSignAdd', { fg = '#62b543' })
  set('JetGitSignChange', { fg = '#3592c4' })
  set('JetGitSignDelete', { fg = '#c75450' })
  set('JetGitTitle', { link = 'Title' })
  set('JetGitDim', { link = 'Comment' })
  set('JetGitStaged', { fg = '#62b543' })
  set('JetGitUnstaged', { fg = '#3592c4' })
  set('JetGitUntracked', { fg = '#d1675a' })
  set('JetGitConflictEntry', { link = 'ErrorMsg' })
  set('JetGitLogHash', { fg = '#c57e33' })
  set('JetGitLogDate', { link = 'Comment' })
  set('JetGitLogRefs', { fg = '#3592c4', bold = true })
end

--- Compute hunks between index text and buffer text.
--- Each hunk: { sa, ca, sb, cb, type, first, last } (first/last = display lines).
local function compute_hunks(index_lines, buf)
  local a = #index_lines > 0 and (table.concat(index_lines, '\n') .. '\n') or ''
  local blines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local b = table.concat(blines, '\n') .. '\n'
  local ok, idx = pcall(diff_fn, a, b, { result_type = 'indices' })
  if not ok or type(idx) ~= 'table' then
    return {}
  end
  local hunks = {}
  for _, h in ipairs(idx) do
    local sa, ca, sb, cb = h[1], h[2], h[3], h[4]
    local t = (ca == 0 and 'add') or (cb == 0 and 'delete') or 'change'
    local first, last
    if t == 'delete' then
      first = math.max(sb, 1)
      last = first
    else
      first = sb
      last = sb + cb - 1
    end
    table.insert(hunks, { sa = sa, ca = ca, sb = sb, cb = cb, type = t, first = first, last = last })
  end
  return hunks
end

local function place_signs(buf, hunks)
  fn.sign_unplace('jetgit', { buffer = buf })
  local list = {}
  local line_count = api.nvim_buf_line_count(buf)
  for _, h in ipairs(hunks) do
    if h.type == 'delete' then
      if h.first <= line_count then
        table.insert(list, { buffer = buf, group = 'jetgit', lnum = h.first, name = 'JetGitDelete', priority = 6 })
      end
    else
      local name = h.type == 'add' and 'JetGitAdd' or 'JetGitChange'
      for l = h.first, math.min(h.last, line_count) do
        table.insert(list, { buffer = buf, group = 'jetgit', lnum = l, name = name, priority = 6 })
      end
    end
  end
  if #list > 0 then
    fn.sign_placelist(list)
  end
end

function M.update(buf)
  buf = buf or api.nvim_get_current_buf()
  local c = cache[buf]
  if not c or not c.tracked then
    return
  end
  if api.nvim_buf_line_count(buf) > MAX_LINES then
    return
  end
  c.hunks = compute_hunks(c.index_lines, buf)
  place_signs(buf, c.hunks)
end

local function detach(buf)
  cache[buf] = nil
  pcall(fn.sign_unplace, 'jetgit', { buffer = buf })
end

--- (Re)load the index version of the file backing this buffer.
function M.refresh_index(buf)
  buf = buf or api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= '' then
    return
  end
  local file = api.nvim_buf_get_name(buf)
  if file == '' or file:match('^%w+://') then
    return
  end
  local root = util.git_root(file)
  if not root then
    detach(buf)
    return
  end
  local rel = util.relpath(root, file)
  local lines, ok = util.git(root, { 'show', ':0:' .. rel })
  if not ok then
    -- untracked or not in index: no gutter (same as JetBrains unversioned files)
    detach(buf)
    return
  end
  cache[buf] = { root = root, rel = rel, tracked = true, index_lines = lines, hunks = {} }
  M.update(buf)
end

function M.refresh_all()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == '' then
      M.refresh_index(buf)
    end
  end
end

local function schedule_update(buf)
  if pending[buf] then
    return
  end
  pending[buf] = true
  vim.defer_fn(function()
    pending[buf] = nil
    if api.nvim_buf_is_valid(buf) then
      M.update(buf)
    end
  end, 150)
end

--- Hunks of a buffer (may be empty).
function M.hunks(buf)
  local c = cache[buf or api.nvim_get_current_buf()]
  return c and c.hunks or {}
end

local function hunk_at(buf, lnum)
  for _, h in ipairs(M.hunks(buf)) do
    if lnum >= h.first and lnum <= h.last then
      return h
    end
  end
end

function M.next_hunk()
  local buf = api.nvim_get_current_buf()
  local lnum = api.nvim_win_get_cursor(0)[1]
  local hunks = M.hunks(buf)
  if #hunks == 0 then
    util.notify('No changes in this file')
    return
  end
  for _, h in ipairs(hunks) do
    if h.first > lnum then
      api.nvim_win_set_cursor(0, { h.first, 0 })
      return
    end
  end
  api.nvim_win_set_cursor(0, { hunks[1].first, 0 }) -- wrap
end

function M.prev_hunk()
  local buf = api.nvim_get_current_buf()
  local lnum = api.nvim_win_get_cursor(0)[1]
  local hunks = M.hunks(buf)
  if #hunks == 0 then
    util.notify('No changes in this file')
    return
  end
  for i = #hunks, 1, -1 do
    if hunks[i].last < lnum then
      api.nvim_win_set_cursor(0, { hunks[i].first, 0 })
      return
    end
  end
  api.nvim_win_set_cursor(0, { hunks[#hunks].first, 0 }) -- wrap
end

--- Floating preview of the hunk under the cursor (old vs new lines).
function M.preview_hunk()
  local buf = api.nvim_get_current_buf()
  local c = cache[buf]
  local lnum = api.nvim_win_get_cursor(0)[1]
  local h = c and hunk_at(buf, lnum)
  if not h then
    util.notify('No change under cursor')
    return
  end
  local lines = { string.format('@@ -%d,%d +%d,%d @@', h.sa, h.ca, h.sb, h.cb) }
  for i = h.sa, h.sa + h.ca - 1 do
    table.insert(lines, '-' .. (c.index_lines[i] or ''))
  end
  local new_lines = api.nvim_buf_get_lines(buf, h.sb - 1, h.sb - 1 + h.cb, false)
  for _, l in ipairs(new_lines) do
    table.insert(lines, '+' .. l)
  end
  local float_buf = util.scratch(lines, { name = 'hunk-preview', filetype = 'diff' })
  local width = 40
  for _, l in ipairs(lines) do
    width = math.max(width, fn.strdisplaywidth(l) + 2)
  end
  width = math.min(width, vim.o.columns - 4)
  local win = api.nvim_open_win(float_buf, false, {
    relative = 'cursor',
    row = 1,
    col = 0,
    width = width,
    height = math.min(#lines, 20),
    style = 'minimal',
    border = 'rounded',
  })
  api.nvim_create_autocmd({ 'CursorMoved', 'BufLeave', 'InsertEnter' }, {
    buffer = buf,
    once = true,
    callback = function()
      if api.nvim_win_is_valid(win) then
        api.nvim_win_close(win, true)
      end
    end,
  })
end

--- Revert one hunk in the buffer back to the index version.
local function apply_rollback(buf, c, h)
  if h.type == 'add' then
    api.nvim_buf_set_lines(buf, h.sb - 1, h.sb - 1 + h.cb, false, {})
  elseif h.type == 'delete' then
    local orig = {}
    for i = h.sa, h.sa + h.ca - 1 do
      table.insert(orig, c.index_lines[i])
    end
    api.nvim_buf_set_lines(buf, h.sb, h.sb, false, orig)
  else -- change
    local orig = {}
    for i = h.sa, h.sa + h.ca - 1 do
      table.insert(orig, c.index_lines[i])
    end
    api.nvim_buf_set_lines(buf, h.sb - 1, h.sb - 1 + h.cb, false, orig)
  end
end

--- Rollback all changed ranges touching lines [l1, l2] (JetBrains Rollback Lines).
function M.rollback(l1, l2)
  local buf = api.nvim_get_current_buf()
  local c = cache[buf]
  if not c or not c.tracked then
    util.notify('File is not tracked by git', vim.log.levels.WARN)
    return
  end
  M.update(buf) -- make sure hunks are current
  local selected = {}
  for _, h in ipairs(c.hunks) do
    if h.first <= l2 and h.last >= l1 then
      table.insert(selected, h)
    end
  end
  if #selected == 0 then
    util.notify('No change to rollback here')
    return
  end
  for i = #selected, 1, -1 do -- bottom-up so line numbers stay valid
    apply_rollback(buf, c, selected[i])
  end
  M.update(buf)
  util.notify(string.format('Rolled back %d change%s', #selected, #selected > 1 and 's' or ''))
end

function M.setup()
  define_highlights()
  api.nvim_create_autocmd('ColorScheme', {
    group = api.nvim_create_augroup('JetGitHl', { clear = true }),
    callback = define_highlights,
  })

  fn.sign_define('JetGitAdd', { text = '┃', texthl = 'JetGitSignAdd' })
  fn.sign_define('JetGitChange', { text = '┃', texthl = 'JetGitSignChange' })
  fn.sign_define('JetGitDelete', { text = '▁', texthl = 'JetGitSignDelete' })

  local group = api.nvim_create_augroup('JetGitSigns', { clear = true })
  api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
    group = group,
    callback = function(ev)
      M.refresh_index(ev.buf)
    end,
  })
  api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'InsertLeave' }, {
    group = group,
    callback = function(ev)
      if cache[ev.buf] then
        schedule_update(ev.buf)
      end
    end,
  })
  api.nvim_create_autocmd('FocusGained', {
    group = group,
    callback = function()
      M.refresh_all()
    end,
  })
  api.nvim_create_autocmd('BufDelete', {
    group = group,
    callback = function(ev)
      cache[ev.buf] = nil
    end,
  })
end

return M
