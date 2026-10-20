if vim.g.loaded_code_scrollbar_plugin then
  return
end
vim.g.loaded_code_scrollbar_plugin = true

require('code-scrollbar').setup()
