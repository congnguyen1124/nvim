if vim.g.loaded_python_pro_plugin then
  return
end
vim.g.loaded_python_pro_plugin = true

require('python-pro').setup()
