local M = {}

local function setup_illuminate()
  local ok, illuminate = pcall(require, 'illuminate')
  if not ok then
    return
  end

  illuminate.configure({
    delay = 200,
    providers = { 'lsp', 'regex' },
    filetypes_denylist = {
      'gitcommit',
      'help',
      'alpha',
      'dashboard',
      'packer',
      'NeogitStatus',
      'Outline',
      'Trouble',
    },
    modes_denylist = { 'i' },
  })

  local highlight = { underline = true }
  vim.api.nvim_set_hl(0, 'IlluminatedWordText', highlight)
  vim.api.nvim_set_hl(0, 'IlluminatedWordRead', highlight)
  vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', highlight)
end

function M.setup()
  setup_illuminate()
end

return M
