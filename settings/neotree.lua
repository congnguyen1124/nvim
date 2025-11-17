if vim.g.loaded_custom_neotree then
  return
end
vim.g.loaded_custom_neotree = true

local ok, neotree = pcall(require, 'neo-tree')
if not ok then
  return
end

vim.keymap.set('n', '<C-B>', '<cmd>Neotree toggle reveal_force_cwd<CR>', { silent = true, desc = 'Toggle Neo-tree' })

neotree.setup({
  close_if_last_window = true,
  sources = { 'filesystem', 'buffers', 'git_status' },
  filesystem = {
    follow_current_file = { enabled = true },
    hijack_netrw_behavior = 'open_default',
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
  window = {
    width = 32,
    mappings = {
      ['<C-B>'] = 'close_window',
    },
  },
})
