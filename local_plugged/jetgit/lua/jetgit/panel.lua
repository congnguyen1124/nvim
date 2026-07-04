-- jetgit/panel.lua - JetBrains-style Git tool window (bottom panel)
-- with two sections: Local Changes and Log.
local util = require('jetgit.util')

local M = {}

local api = vim.api
local fn = vim.fn

local state = {
  buf = nil,
  win = nil,
  root = nil,
  section = 'changes', -- 'changes' | 'log'
  entries = {}, -- line -> entry (changes section)
  hashes = {}, -- line -> commit hash (log section)
  branch_line = '',
}

local HEIGHT = 15
local LOG_COUNT = 200

local function win_valid()
  return state.win and api.nvim_win_is_valid(state.win)
end

local function buf_valid()
  return state.buf and api.nvim_buf_is_valid(state.buf)
end

local function hl(line, group)
  api.nvim_buf_add_highlight(state.buf, -1, group, line - 1, 0, -1)
end

local function set_lines(lines)
  vim.bo[state.buf].modifiable = true
  api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.bo[state.buf].modifiable = false
end

-- ---------------------------------------------------------------- rendering

local function parse_status(out)
  local branch = ''
  local groups = { conflicts = {}, staged = {}, unstaged = {}, untracked = {} }
  for _, line in ipairs(out) do
    if line:sub(1, 2) == '##' then
      branch = line:sub(4)
    else
      local x, y = line:sub(1, 1), line:sub(2, 2)
      local path = line:sub(4)
      local arrow = path:find(' %-> ')
      local display = path
      if arrow then
        path = path:sub(arrow + 4)
        display = display -- keep "old -> new" for display
      end
      local xy = x .. y
      if xy == '??' then
        table.insert(groups.untracked, { status = '??', path = path, display = display, group = 'untracked' })
      elseif xy == 'DD' or xy == 'AA' or x == 'U' or y == 'U' then
        table.insert(groups.conflicts, { status = xy, path = path, display = display, group = 'conflicts' })
      else
        if x ~= ' ' then
          table.insert(groups.staged, { status = x .. ' ', path = path, display = display, group = 'staged' })
        end
        if y ~= ' ' then
          table.insert(groups.unstaged, { status = ' ' .. y, path = path, display = display, group = 'unstaged' })
        end
      end
    end
  end
  return branch, groups
end

local function render_changes()
  local out, ok = util.git(state.root, { 'status', '--porcelain=v1', '-b' })
  if not ok then
    set_lines({ ' Not a git repository' })
    return
  end
  local branch, groups = parse_status(out)
  state.entries = {}

  local lines = {
    '  Local Changes                        [Tab] Log   [?] Help   [q] Close',
    '  ⎇ ' .. branch,
    '',
  }
  local marks = { { 1, 'JetGitTitle' }, { 2, 'JetGitDim' } }

  local function section(title, items, group_hl)
    if #items == 0 then
      return
    end
    table.insert(lines, string.format('  ▼ %s (%d)', title, #items))
    table.insert(marks, { #lines, 'JetGitTitle' })
    for _, e in ipairs(items) do
      table.insert(lines, string.format('     %s  %s', e.status, e.display))
      state.entries[#lines] = e
      table.insert(marks, { #lines, group_hl })
    end
    table.insert(lines, '')
  end

  section('Conflicts', groups.conflicts, 'JetGitConflictEntry')
  section('Staged Changes', groups.staged, 'JetGitStaged')
  section('Unstaged Changes', groups.unstaged, 'JetGitUnstaged')
  section('Untracked Files', groups.untracked, 'JetGitUntracked')

  if #groups.conflicts + #groups.staged + #groups.unstaged + #groups.untracked == 0 then
    table.insert(lines, '  ✓ Nothing to commit, working tree clean')
    table.insert(marks, { #lines, 'JetGitDim' })
  end

  table.insert(lines, '')
  table.insert(lines, '  [CR] diff  [o] open  [s] stage/unstage  [a] stage all  [r] rollback  [m] merge  [c] commit  [P] push  [u] pull  [R] refresh')
  table.insert(marks, { #lines, 'JetGitDim' })

  set_lines(lines)
  for _, m in ipairs(marks) do
    hl(m[1], m[2])
  end
end

local function render_log()
  local out, ok = util.git(state.root, {
    'log', '--graph', '--all', '-n', tostring(LOG_COUNT),
    '--date=format:%Y-%m-%d %H:%M',
    '--pretty=format:%h %ad %an%d %s',
  })
  if not ok then
    out = { ' (no commits)' }
  end
  state.hashes = {}
  local lines = {
    '  Log                                  [Tab] Local Changes   [?] Help   [q] Close',
    '',
  }
  for _, l in ipairs(out) do
    table.insert(lines, '  ' .. l)
    local hash = l:match('^[%s%*|/\\_%.%-]*(%x%x%x%x%x%x%x+)%s')
    if hash then
      state.hashes[#lines] = hash
    end
  end
  set_lines(lines)
  hl(1, 'JetGitTitle')
end

function M.refresh()
  if not buf_valid() then
    return
  end
  if state.section == 'changes' then
    render_changes()
  else
    render_log()
  end
end

-- ------------------------------------------------------------------ actions

local function entry_under_cursor()
  local lnum = api.nvim_win_get_cursor(0)[1]
  return state.entries[lnum]
end

local function after_git_change()
  M.refresh()
  require('jetgit.signs').refresh_all()
end

local function do_diff()
  if state.section == 'log' then
    local lnum = api.nvim_win_get_cursor(0)[1]
    local hash = state.hashes[lnum]
    if not hash then
      return
    end
    M.show_commit(hash)
    return
  end
  local e = entry_under_cursor()
  if not e then
    return
  end
  local abs = state.root .. '/' .. e.path
  if e.group == 'conflicts' then
    util.goto_main_win(state.win)
    require('jetgit.conflict').merge_view(abs)
  elseif e.group == 'staged' then
    require('jetgit.diff').open({ file = abs, staged = true })
  else
    require('jetgit.diff').open({ file = abs })
  end
end

local function do_open()
  local e = entry_under_cursor()
  if not e then
    return
  end
  local abs = state.root .. '/' .. e.path
  util.goto_main_win(state.win)
  vim.cmd('edit ' .. fn.fnameescape(abs))
end

local function do_stage()
  local e = entry_under_cursor()
  if not e then
    return
  end
  local args
  if e.group == 'staged' then
    args = { 'reset', '-q', '--', e.path } -- unstage
  else
    args = { 'add', '--', e.path } -- stage (also marks conflicts resolved)
  end
  local err, ok = util.git(state.root, args)
  if not ok then
    util.notify(table.concat(err, '\n'), vim.log.levels.ERROR)
  end
  after_git_change()
end

local function do_stage_all()
  util.git(state.root, { 'add', '-A' })
  after_git_change()
end

local function do_rollback()
  local e = entry_under_cursor()
  if not e then
    return
  end
  if e.group == 'untracked' then
    local choice = fn.confirm('Delete untracked file ' .. e.path .. '?', '&Yes\n&No', 2)
    if choice == 1 then
      os.remove(state.root .. '/' .. e.path)
      after_git_change()
    end
    return
  end
  local choice = fn.confirm('Rollback ' .. e.path .. ' to HEAD?', '&Yes\n&No', 2)
  if choice ~= 1 then
    return
  end
  local err, ok = util.git(state.root, { 'checkout', 'HEAD', '--', e.path })
  if not ok then
    util.notify(table.concat(err, '\n'), vim.log.levels.ERROR)
  else
    util.notify('Rolled back ' .. e.path)
    -- reload the buffer if this file is open
    for _, buf in ipairs(api.nvim_list_bufs()) do
      if api.nvim_buf_is_loaded(buf) and api.nvim_buf_get_name(buf) == state.root .. '/' .. e.path then
        api.nvim_buf_call(buf, function()
          vim.cmd('silent! edit!')
        end)
      end
    end
  end
  after_git_change()
end

local function do_merge()
  local e = entry_under_cursor()
  if not e or e.group ~= 'conflicts' then
    util.notify('Place the cursor on a conflicted file')
    return
  end
  util.goto_main_win(state.win)
  require('jetgit.conflict').merge_view(state.root .. '/' .. e.path)
end

function M.commit(amend)
  local root = state.root or util.current_root()
  if not root then
    util.notify('Not inside a git repository', vim.log.levels.WARN)
    return
  end
  local staged = util.git(root, { 'diff', '--cached', '--name-only' })
  if #staged == 0 and not amend then
    local choice = fn.confirm('Nothing staged. Stage all changes and commit?', '&Yes\n&No', 2)
    if choice ~= 1 then
      return
    end
    util.git(root, { 'add', '-A' })
  end
  if amend then
    local choice = fn.confirm('Amend last commit (keep message)?', '&Yes\n&No', 2)
    if choice ~= 1 then
      return
    end
    local out, ok = util.git(root, { 'commit', '--amend', '--no-edit' })
    util.notify(ok and (out[1] or 'Amended') or table.concat(out, '\n'), ok and nil or vim.log.levels.ERROR)
    after_git_change()
    return
  end
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if not msg or msg == '' then
      return
    end
    local out, ok = util.git(root, { 'commit', '-m', msg })
    util.notify(ok and (out[1] or 'Committed') or table.concat(out, '\n'), ok and nil or vim.log.levels.ERROR)
    after_git_change()
  end)
end

local function remote_op(name, args)
  local root = state.root or util.current_root()
  if not root then
    util.notify('Not inside a git repository', vim.log.levels.WARN)
    return
  end
  util.notify(name .. '...')
  util.git_async(root, args, function(ok, out, err)
    local msg = table.concat(ok and (#out > 0 and out or err) or err, '\n')
    if msg == '' then
      msg = name .. ' done'
    end
    util.notify(msg, ok and nil or vim.log.levels.ERROR)
    if buf_valid() then
      M.refresh()
    end
    require('jetgit.signs').refresh_all()
  end)
end

function M.push() remote_op('Push', { 'push' }) end
function M.pull() remote_op('Pull', { 'pull' }) end
function M.fetch() remote_op('Fetch', { 'fetch', '--all' }) end

--- Show a commit (files + patch) in the main window, like the JetBrains
--- commit details pane.
function M.show_commit(hash)
  local out, ok = util.git(state.root, { 'show', '--stat', '--patch', '--format=fuller', hash })
  if not ok then
    util.notify('Cannot show ' .. hash, vim.log.levels.ERROR)
    return
  end
  util.goto_main_win(state.win)
  local buf = util.scratch(out, { name = 'commit/' .. hash, filetype = 'git' })
  api.nvim_win_set_buf(0, buf)
  vim.keymap.set('n', 'q', '<cmd>bwipeout<CR>', { buffer = buf, silent = true })
end

local function yank_hash()
  local lnum = api.nvim_win_get_cursor(0)[1]
  local hash = state.hashes[lnum]
  if hash then
    fn.setreg('+', hash)
    fn.setreg('"', hash)
    util.notify('Yanked ' .. hash)
  end
end

local function toggle_section()
  state.section = state.section == 'changes' and 'log' or 'changes'
  M.refresh()
end

local function show_help()
  local lines = {
    ' JetGit panel keys',
    ' ─────────────────',
    ' Tab      switch Local Changes <-> Log',
    ' Enter    changes: open diff / log: show commit',
    ' o        open file in editor',
    ' s        stage / unstage file (also: mark conflict resolved)',
    ' a        stage all changes',
    ' r        rollback file to HEAD (delete if untracked)',
    ' m        open 3-way merge view for conflicted file',
    ' c / C    commit / amend last commit',
    ' P        push',
    ' u        pull (update project)',
    ' f        fetch --all',
    ' y        log: yank commit hash',
    ' R        refresh',
    ' q        close panel',
  }
  local buf = util.scratch(lines, { name = 'help' })
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, fn.strdisplaywidth(l) + 2)
  end
  local win = api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = #lines,
    style = 'minimal',
    border = 'rounded',
  })
  vim.keymap.set('n', 'q', function() api.nvim_win_close(win, true) end, { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', function() api.nvim_win_close(win, true) end, { buffer = buf, silent = true })
end

-- -------------------------------------------------------------------- setup

local function attach_maps(buf)
  local map = function(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, silent = true, nowait = true, desc = desc })
  end
  map('<CR>', do_diff, 'Diff / show commit')
  map('o', do_open, 'Open file')
  map('s', do_stage, 'Stage/unstage')
  map('a', do_stage_all, 'Stage all')
  map('r', do_rollback, 'Rollback file')
  map('m', do_merge, 'Merge conflicted file')
  map('c', function() M.commit(false) end, 'Commit')
  map('C', function() M.commit(true) end, 'Amend commit')
  map('P', M.push, 'Push')
  map('u', M.pull, 'Pull')
  map('f', M.fetch, 'Fetch')
  map('y', yank_hash, 'Yank commit hash')
  map('R', M.refresh, 'Refresh')
  map('<Tab>', toggle_section, 'Switch section')
  map('q', M.close, 'Close panel')
  map('?', show_help, 'Help')
end

local function apply_win_opts(win)
  local wo = vim.wo[win]
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = 'no'
  wo.foldcolumn = '0'
  wo.wrap = false
  wo.cursorline = true
  wo.winfixheight = true
  wo.spell = false
  api.nvim_win_call(win, function()
    fn.matchadd('JetGitLogHash', [[\v^[ *|/\\_.-]*\zs\x{7,40}\ze\s]])
    fn.matchadd('JetGitLogDate', [[\v\d{4}-\d{2}-\d{2} \d{2}:\d{2}]])
    fn.matchadd('JetGitLogRefs', [[\v\(HEAD[^)]*\)|\(origin/[^)]*\)|\(tag: [^)]*\)]])
  end)
end

function M.close()
  if win_valid() then
    api.nvim_win_close(state.win, true)
  end
  state.win = nil
end

function M.is_open()
  return win_valid()
end

function M.current_section()
  return state.section
end

function M.open(section)
  local root = util.current_root()
  if not root then
    util.notify('Not inside a git repository', vim.log.levels.WARN)
    return
  end
  state.root = root
  if section then
    state.section = section
  end
  if not buf_valid() then
    state.buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_name(state.buf, 'jetgit://panel')
    vim.bo[state.buf].buftype = 'nofile'
    vim.bo[state.buf].bufhidden = 'hide'
    vim.bo[state.buf].swapfile = false
    vim.bo[state.buf].filetype = 'jetgit'
    attach_maps(state.buf)
  end
  if not win_valid() then
    vim.cmd('botright ' .. HEIGHT .. 'split')
    state.win = api.nvim_get_current_win()
    api.nvim_win_set_buf(state.win, state.buf)
    apply_win_opts(state.win)
  else
    api.nvim_set_current_win(state.win)
  end
  M.refresh()
end

function M.toggle()
  if win_valid() then
    M.close()
  else
    M.open()
  end
end

return M
