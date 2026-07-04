-- jetgit user commands
if vim.g.loaded_jetgit then
  return
end
vim.g.loaded_jetgit = 1

local command = vim.api.nvim_create_user_command

command('JetGit', function()
  require('jetgit.panel').toggle()
end, { desc = 'Toggle the Git tool window' })

command('JetGitLog', function()
  require('jetgit.panel').open('log')
end, { desc = 'Open the Git tool window on the Log section' })

command('JetGitDiff', function()
  require('jetgit.diff').open()
end, { desc = 'Diff current file against the index' })

command('JetGitRollback', function(opts)
  local l1, l2
  if opts.range > 0 then
    l1, l2 = opts.line1, opts.line2
  else
    l1 = vim.api.nvim_win_get_cursor(0)[1]
    l2 = l1
  end
  require('jetgit.signs').rollback(l1, l2)
end, { range = true, desc = 'Rollback changed lines to the index version' })

command('JetGitPreviewHunk', function()
  require('jetgit.signs').preview_hunk()
end, { desc = 'Preview the change under the cursor' })

command('JetGitNextHunk', function()
  require('jetgit.signs').next_hunk()
end, { desc = 'Jump to next change' })

command('JetGitPrevHunk', function()
  require('jetgit.signs').prev_hunk()
end, { desc = 'Jump to previous change' })

command('JetGitCommit', function(opts)
  require('jetgit.panel').commit(opts.bang)
end, { bang = true, desc = 'Commit (with ! amend last commit)' })

command('JetGitPush', function()
  require('jetgit.panel').push()
end, { desc = 'git push' })

command('JetGitPull', function()
  require('jetgit.panel').pull()
end, { desc = 'git pull' })

command('JetGitFetch', function()
  require('jetgit.panel').fetch()
end, { desc = 'git fetch --all' })

command('JetGitMerge', function()
  require('jetgit.conflict').merge_view()
end, { desc = 'Open 3-way merge view for the current conflicted file' })

command('JetGitRefresh', function()
  require('jetgit.signs').refresh_all()
  pcall(function() require('jetgit.panel').refresh() end)
end, { desc = 'Refresh gutter marks and panel' })
