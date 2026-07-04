-- jetgit/diff.lua - JetBrains-style side-by-side diff viewer (opens in a new tab).
local util = require('jetgit.util')

local M = {}

local api = vim.api
local fn = vim.fn

local function set_diff_win_opts()
  vim.wo.wrap = false
  vim.wo.foldmethod = 'diff'
end

local function scratch_in_current_win(lines, name, filetype)
  local buf = util.show_scratch_here(lines, { name = name, filetype = filetype })
  vim.keymap.set('n', 'q', '<cmd>tabclose<CR>', { buffer = buf, silent = true, desc = 'Close diff tab' })
  return buf
end

--- Diff the working file against the index version (JetBrains "Show Diff").
--- opts = { file = <abs path>, staged = <bool> }
---   staged=true  : HEAD vs index (both readonly)
---   staged=false : index vs working file (right side editable)
function M.open(opts)
  opts = opts or {}
  local file = opts.file or api.nvim_buf_get_name(0)
  if file == '' then
    util.notify('No file to diff', vim.log.levels.WARN)
    return
  end
  local root = util.git_root(file)
  if not root then
    util.notify('Not inside a git repository', vim.log.levels.WARN)
    return
  end
  local rel = util.relpath(root, file)
  local ft = vim.filetype.match({ filename = file }) or ''

  if opts.staged then
    local index_lines, ok = util.git(root, { 'show', ':0:' .. rel })
    if not ok then
      util.notify('File is not in the index', vim.log.levels.WARN)
      return
    end
    local head_lines, head_ok = util.git(root, { 'show', 'HEAD:' .. rel })
    if not head_ok then
      head_lines = {} -- newly added file
    end
    vim.cmd('tabnew')
    scratch_in_current_win(index_lines, 'INDEX/' .. rel, ft)
    vim.cmd('diffthis')
    set_diff_win_opts()
    vim.cmd('leftabove vertical new')
    scratch_in_current_win(head_lines, 'HEAD/' .. rel, ft)
    vim.cmd('diffthis')
    set_diff_win_opts()
    vim.cmd('wincmd l')
    return
  end

  local base_lines, ok = util.git(root, { 'show', ':0:' .. rel })
  local base_name = 'INDEX/' .. rel
  if not ok then
    base_lines = {} -- untracked: diff against empty, like JetBrains
    base_name = 'EMPTY/' .. rel
  end
  vim.cmd('tabedit ' .. fn.fnameescape(file))
  vim.cmd('diffthis')
  set_diff_win_opts()
  vim.cmd('leftabove vertical new')
  scratch_in_current_win(base_lines, base_name, ft)
  vim.cmd('diffthis')
  set_diff_win_opts()
  vim.cmd('wincmd l') -- focus the editable side
end

--- Show what a commit did to one file: parent vs commit (both readonly).
function M.open_rev(root, rel, rev)
  local ft = vim.filetype.match({ filename = rel }) or ''
  local new_lines, ok = util.git(root, { 'show', rev .. ':' .. rel })
  if not ok then
    new_lines = {} -- deleted by this commit
  end
  local old_lines, old_ok = util.git(root, { 'show', rev .. '^:' .. rel })
  if not old_ok then
    old_lines = {} -- added by this commit
  end
  vim.cmd('tabnew')
  scratch_in_current_win(new_lines, rev:sub(1, 8) .. '/' .. rel, ft)
  vim.cmd('diffthis')
  set_diff_win_opts()
  vim.cmd('leftabove vertical new')
  scratch_in_current_win(old_lines, rev:sub(1, 8) .. '~1/' .. rel, ft)
  vim.cmd('diffthis')
  set_diff_win_opts()
  vim.cmd('wincmd l')
end

return M
