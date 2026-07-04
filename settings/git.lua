-- JetGit: local plugin (local_plugged/jetgit) - JetBrains-style git UI.
-- Keymaps mirror the JetBrains defaults where the terminal allows it.
local ok, jetgit = pcall(require, 'jetgit')
if not ok then
  return
end
jetgit.setup()

-- Show current branch in airline section b (replaces fugitive integration)
vim.g['airline#extensions#branch#enabled'] = 0
vim.g.airline_section_b = '%{get(g:, "jetgit_branch", "")}'

local map = vim.keymap.set
local opts = function(desc)
  return { silent = true, desc = desc }
end

-- Git tool window (JetBrains: Alt+9)
map('n', '<M-9>', '<cmd>JetGit<CR>', opts('Git: toggle tool window'))
map('n', '<leader>gg', '<cmd>JetGit<CR>', opts('Git: toggle tool window'))
map('n', '<leader>gL', '<cmd>JetGitLog<CR>', opts('Git: log section'))

-- Show diff (JetBrains: Ctrl+D)
map('n', '<M-d>', '<cmd>JetGitDiff<CR>', opts('Git: diff current file'))
map('n', '<leader>gd', '<cmd>JetGitDiff<CR>', opts('Git: diff current file'))

-- Rollback lines (JetBrains: Ctrl+Alt+Z)
map('n', '<M-z>', '<cmd>JetGitRollback<CR>', opts('Git: rollback change at cursor'))
map('n', '<leader>gr', '<cmd>JetGitRollback<CR>', opts('Git: rollback change at cursor'))
map('x', '<M-z>', ':JetGitRollback<CR>', opts('Git: rollback selected lines'))
map('x', '<leader>gr', ':JetGitRollback<CR>', opts('Git: rollback selected lines'))

-- Hunk preview and navigation
map('n', '<leader>gp', '<cmd>JetGitPreviewHunk<CR>', opts('Git: preview change at cursor'))
map('n', ']c', function()
  if vim.wo.diff then
    return ']c'
  end
  vim.schedule(function()
    require('jetgit.signs').next_hunk()
  end)
  return '<Ignore>'
end, { expr = true, silent = true, desc = 'Git: next change' })
map('n', '[c', function()
  if vim.wo.diff then
    return '[c'
  end
  vim.schedule(function()
    require('jetgit.signs').prev_hunk()
  end)
  return '<Ignore>'
end, { expr = true, silent = true, desc = 'Git: previous change' })

-- Commit (JetBrains: Ctrl+K) / push / pull / fetch
map('n', '<M-k>', '<cmd>JetGitCommit<CR>', opts('Git: commit'))
map('n', '<leader>gc', '<cmd>JetGitCommit<CR>', opts('Git: commit'))
map('n', '<leader>gP', '<cmd>JetGitPush<CR>', opts('Git: push'))
map('n', '<leader>gu', '<cmd>JetGitPull<CR>', opts('Git: pull (update project)'))
map('n', '<leader>gf', '<cmd>JetGitFetch<CR>', opts('Git: fetch'))

-- Conflict resolution (3-way merge view, like the JetBrains merge dialog)
map('n', '<leader>gm', '<cmd>JetGitMerge<CR>', opts('Git: resolve conflicts (3-way merge)'))
