-- jetgit - a small local plugin that recreates the JetBrains IDE git UX:
--   * gutter marks for changed lines + "Rollback Lines"
--   * a Git tool window with Local Changes and Log sections
--   * side-by-side diff viewer
--   * 3-way merge view for conflict resolution
local M = {}

function M.setup()
  require('jetgit.signs').setup()
  require('jetgit.conflict').setup()
  require('jetgit.util').setup_branch_autocmd()
end

return M
