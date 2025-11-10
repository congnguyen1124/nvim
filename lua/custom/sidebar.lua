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
      'nerdtree',
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

local function should_hide_minimap(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return true
  end

  local bt = vim.bo[buf].buftype
  if bt ~= '' and bt ~= 'acwrite' then
    return true
  end

  local ft = vim.bo[buf].filetype
  if ft == 'nerdtree' or ft == 'startuptime' or ft == 'gitcommit' then
    return true
  end

  if vim.api.nvim_buf_line_count(buf) < 15 then
    return true
  end

  return false
end

local function setup_minimap()
  local ok, mini_map = pcall(require, 'mini.map')
  if not ok then
    return
  end

  mini_map.setup({
    integrations = {
      mini_map.gen_integration.builtin_search(),
      mini_map.gen_integration.diagnostic(),
      mini_map.gen_integration.gitsigns(),
    },
    symbols = {
      encode = mini_map.gen_encode_symbols.dot('4x2'),
      scroll_line = '-',
      scroll_view = '|',
    },
    window = {
      focusable = false,
      side = 'right',
      show_integration_count = false,
      width = 10,
      winblend = 0,
      zindex = 1,
    },
  })

  local group = vim.api.nvim_create_augroup('CustomMiniMap', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
    group = group,
    callback = function(event)
      local buf = event.buf
      if buf == 0 then
        buf = vim.api.nvim_get_current_buf()
      end
      if should_hide_minimap(buf) then
        mini_map.close()
        return
      end

      mini_map.open()
      mini_map.refresh()
    end,
  })

  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI', 'WinScrolled' }, {
    group = group,
    callback = function(event)
      local buf = event.buf
      if buf == 0 then
        buf = vim.api.nvim_get_current_buf()
      end
      if should_hide_minimap(buf) then
        mini_map.close()
        return
      end

      mini_map.refresh()
    end,
  })

  vim.keymap.set('n', '<leader>mm', mini_map.toggle, { desc = 'Toggle minimap' })
end

function M.setup()
  setup_illuminate()
  setup_minimap()
end

return M
