-- jetgit/util.lua - git helpers shared by all jetgit modules
local M = {}

local fn = vim.fn
local api = vim.api

local root_cache = {}

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'JetGit' })
end

--- Run git synchronously. Returns (lines, ok).
function M.git(root, args)
  local cmd = { 'git' }
  if root then
    vim.list_extend(cmd, { '-C', root })
  end
  vim.list_extend(cmd, args)
  local out = fn.systemlist(cmd)
  return out, vim.v.shell_error == 0
end

--- Run git asynchronously. cb(ok, stdout_lines, stderr_lines) on the main loop.
function M.git_async(root, args, cb)
  local cmd = { 'git' }
  if root then
    vim.list_extend(cmd, { '-C', root })
  end
  vim.list_extend(cmd, args)
  local stdout, stderr = {}, {}
  local function collect(dst)
    return function(_, data)
      for _, line in ipairs(data or {}) do
        if line ~= '' then
          table.insert(dst, line)
        end
      end
    end
  end
  fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = collect(stdout),
    on_stderr = collect(stderr),
    on_exit = function(_, code)
      vim.schedule(function()
        cb(code == 0, stdout, stderr)
      end)
    end,
  })
end

--- Git repo root for a path (cached per directory).
function M.git_root(path)
  local dir = path
  if dir == nil or dir == '' then
    dir = fn.getcwd()
  end
  if fn.isdirectory(dir) == 0 then
    dir = fn.fnamemodify(dir, ':h')
  end
  if root_cache[dir] ~= nil then
    return root_cache[dir] or nil
  end
  local out = fn.systemlist({ 'git', '-C', dir, 'rev-parse', '--show-toplevel' })
  local root = (vim.v.shell_error == 0 and out[1]) and out[1] or false
  root_cache[dir] = root
  return root or nil
end

--- Root for the current context: file's repo first, then cwd's repo.
function M.current_root()
  local file = api.nvim_buf_get_name(0)
  local root
  if file ~= '' and vim.bo.buftype == '' then
    root = M.git_root(file)
  end
  return root or M.git_root(fn.getcwd())
end

function M.relpath(root, abs)
  abs = fn.fnamemodify(abs, ':p')
  local prefix = root .. '/'
  if abs:sub(1, #prefix) == prefix then
    return abs:sub(#prefix + 1)
  end
  return abs
end

--- Current branch name, read from .git/HEAD (cheap, no subprocess).
function M.branch(root)
  if not root then
    return ''
  end
  local gitdir = root .. '/.git'
  if fn.isdirectory(gitdir) == 0 then
    -- worktree/submodule: .git is a file "gitdir: <path>"
    local ok, lines = pcall(fn.readfile, gitdir, '', 1)
    if not ok or not lines[1] then
      return ''
    end
    local target = lines[1]:match('^gitdir:%s*(.+)$')
    if not target then
      return ''
    end
    if not target:match('^/') then
      target = root .. '/' .. target
    end
    gitdir = target
  end
  local ok, lines = pcall(fn.readfile, gitdir .. '/HEAD', '', 1)
  if not ok or not lines[1] then
    return ''
  end
  local ref = lines[1]:match('^ref:%s*refs/heads/(.+)$')
  return ref or lines[1]:sub(1, 8)
end

--- Keep g:jetgit_branch updated for the statusline (airline section b).
function M.setup_branch_autocmd()
  local group = api.nvim_create_augroup('JetGitBranch', { clear = true })
  local function update()
    local root = M.current_root()
    local branch = M.branch(root)
    vim.g.jetgit_branch = branch ~= '' and (' ' .. branch) or ''
  end
  api.nvim_create_autocmd({ 'BufEnter', 'FocusGained', 'DirChanged' }, {
    group = group,
    callback = update,
  })
  update()
end

--- Create a readonly scratch buffer filled with lines.
local scratch_id = 0
function M.scratch(lines, opts)
  opts = opts or {}
  scratch_id = scratch_id + 1
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  api.nvim_buf_set_name(buf, string.format('jetgit://%d/%s', scratch_id, opts.name or 'scratch'))
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  if opts.filetype then
    vim.bo[buf].filetype = opts.filetype
  end
  return buf
end

--- Show a scratch buffer in the current window, wiping the empty
--- [No Name] buffer that :new / :tabnew leave behind.
function M.show_scratch_here(lines, opts)
  local old = api.nvim_win_get_buf(0)
  local buf = M.scratch(lines, opts)
  api.nvim_win_set_buf(0, buf)
  if api.nvim_buf_is_valid(old)
    and api.nvim_buf_get_name(old) == ''
    and not vim.bo[old].modified
    and api.nvim_buf_line_count(old) == 1
    and #fn.win_findbuf(old) == 0 then
    pcall(api.nvim_buf_delete, old, { force = true })
  end
  return buf
end

--- Move focus to a "main" (non-panel, non-tree, non-floating) window,
--- creating one if necessary.
function M.goto_main_win(skip_win)
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if win ~= skip_win and api.nvim_win_get_config(win).relative == '' then
      local buf = api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft ~= 'jetgit' and ft ~= 'neo-tree' and ft ~= 'nerdtree' and vim.bo[buf].buftype ~= 'terminal' then
        api.nvim_set_current_win(win)
        return
      end
    end
  end
  vim.cmd('topleft new')
end

return M
