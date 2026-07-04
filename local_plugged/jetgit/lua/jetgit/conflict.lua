-- jetgit/conflict.lua - conflict navigation and a JetBrains-style
-- 3-way merge view: LOCAL (yours) | RESULT (editable) | REMOTE (theirs).
local util = require('jetgit.util')

local M = {}

local api = vim.api
local fn = vim.fn

local MARK_START = '^<<<<<<<'
local MARK_BASE = '^|||||||'
local MARK_MID = '^======='
local MARK_END = '^>>>>>>>'

--- Find the conflict block containing lnum.
--- Returns { start, base, mid, stop } (line numbers, base may be nil).
local function conflict_at(buf, lnum)
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local start
  for i = lnum, 1, -1 do
    if lines[i] and lines[i]:match(MARK_START) then
      start = i
      break
    end
    if lines[i] and lines[i]:match(MARK_END) and i < lnum then
      return nil -- cursor below a closed conflict
    end
  end
  if not start then
    return nil
  end
  local base, mid, stop
  for i = start + 1, #lines do
    local l = lines[i]
    if l:match(MARK_BASE) and not mid then
      base = i
    elseif l:match(MARK_MID) and not mid then
      mid = i
    elseif l:match(MARK_END) then
      stop = i
      break
    end
  end
  if not mid or not stop or stop < lnum then
    return nil
  end
  return { start = start, base = base, mid = mid, stop = stop }
end

--- Resolve the conflict under the cursor.
--- which: 'ours' | 'theirs' | 'both'
function M.choose(which)
  local buf = api.nvim_get_current_buf()
  local lnum = api.nvim_win_get_cursor(0)[1]
  local c = conflict_at(buf, lnum)
  if not c then
    util.notify('No conflict under cursor')
    return
  end
  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local ours, theirs = {}, {}
  for i = c.start + 1, (c.base or c.mid) - 1 do
    table.insert(ours, lines[i])
  end
  for i = c.mid + 1, c.stop - 1 do
    table.insert(theirs, lines[i])
  end
  local repl
  if which == 'ours' then
    repl = ours
  elseif which == 'theirs' then
    repl = theirs
  else
    repl = vim.list_extend(vim.list_slice(ours), theirs)
  end
  api.nvim_buf_set_lines(buf, c.start - 1, c.stop, false, repl)
  util.notify('Accepted ' .. which)
end

function M.next_conflict()
  if fn.search('^<<<<<<<', 'w') == 0 then
    util.notify('No conflicts')
  end
end

function M.prev_conflict()
  if fn.search('^<<<<<<<', 'bw') == 0 then
    util.notify('No conflicts')
  end
end

function M.count(buf)
  buf = buf or api.nvim_get_current_buf()
  local n = 0
  for _, l in ipairs(api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if l:match(MARK_START) then
      n = n + 1
    end
  end
  return n
end

--- Buffer-local conflict keymaps (used in merge view and conflicted buffers).
local function attach_maps(buf)
  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, silent = true, desc = desc })
  end
  map('<leader>co', function() M.choose('ours') end, 'Conflict: accept yours')
  map('<leader>ct', function() M.choose('theirs') end, 'Conflict: accept theirs')
  map('<leader>cb', function() M.choose('both') end, 'Conflict: accept both')
  map(']x', M.next_conflict, 'Next conflict')
  map('[x', M.prev_conflict, 'Previous conflict')
  map('<leader>cd', function() M.done(buf) end, 'Conflict: apply (save + git add)')
end

--- Open the 3-way merge view for a conflicted file.
function M.merge_view(file)
  file = (file and file ~= '') and file or api.nvim_buf_get_name(0)
  if file == '' then
    util.notify('No file', vim.log.levels.WARN)
    return
  end
  local root = util.git_root(file)
  if not root then
    util.notify('Not inside a git repository', vim.log.levels.WARN)
    return
  end
  local rel = util.relpath(root, file)
  local ours, ours_ok = util.git(root, { 'show', ':2:' .. rel })
  local theirs, theirs_ok = util.git(root, { 'show', ':3:' .. rel })
  if not ours_ok or not theirs_ok then
    util.notify('No merge conflict recorded for this file', vim.log.levels.WARN)
    return
  end
  local ft = vim.filetype.match({ filename = file }) or ''

  -- center: the real file (RESULT)
  vim.cmd('tabedit ' .. fn.fnameescape(file))
  local result_buf = api.nvim_get_current_buf()
  vim.cmd('diffthis')
  vim.wo.wrap = false
  attach_maps(result_buf)

  -- left: LOCAL (yours)
  vim.cmd('leftabove vertical new')
  local lbuf = util.show_scratch_here(ours, { name = 'LOCAL/' .. rel, filetype = ft })
  vim.cmd('diffthis')
  vim.wo.wrap = false
  vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = lbuf, silent = true })

  -- right: REMOTE (theirs)
  vim.cmd('wincmd l')
  vim.cmd('rightbelow vertical new')
  local rbuf = util.show_scratch_here(theirs, { name = 'REMOTE/' .. rel, filetype = ft })
  vim.cmd('diffthis')
  vim.wo.wrap = false
  vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = rbuf, silent = true })

  vim.cmd('wincmd h') -- focus RESULT in the middle
  util.notify(('%d conflict(s). <leader>co yours | <leader>ct theirs | <leader>cb both | ]x/[x navigate | <leader>cd apply'):format(M.count(result_buf)))
end

--- Finish resolving: write the file, git add it, close the merge tab.
function M.done(buf)
  buf = buf or api.nvim_get_current_buf()
  if M.count(buf) > 0 then
    util.notify('Conflict markers still present', vim.log.levels.WARN)
    return
  end
  local file = api.nvim_buf_get_name(buf)
  local root = util.git_root(file)
  api.nvim_buf_call(buf, function()
    vim.cmd('silent write')
  end)
  local _, ok = util.git(root, { 'add', '--', util.relpath(root, file) })
  if ok then
    util.notify('Resolved and staged ' .. util.relpath(root, file))
  end
  pcall(vim.cmd, 'tabclose')
  pcall(function() require('jetgit.panel').refresh() end)
  require('jetgit.signs').refresh_all()
end

--- Attach conflict maps automatically when a file with markers is opened.
function M.setup()
  api.nvim_create_autocmd('BufReadPost', {
    group = api.nvim_create_augroup('JetGitConflict', { clear = true }),
    callback = function(ev)
      if vim.bo[ev.buf].buftype ~= '' then
        return
      end
      if M.count(ev.buf) > 0 then
        attach_maps(ev.buf)
        util.notify('Conflicts detected. Use :JetGitMerge for the 3-way view')
      end
    end,
  })
end

return M
