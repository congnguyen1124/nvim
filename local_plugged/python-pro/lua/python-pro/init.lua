local M = {}

local api = vim.api
local theme = require('python-pro.theme')
local venv = require('python-pro.venv')
local warned_about_ruff = false

local function ensure_python_buffer()
  if vim.bo.filetype ~= 'python' then
    vim.notify('This command is only available in Python buffers.', vim.log.levels.WARN)
    return false
  end
  return true
end

local function coc_action(action, ...)
  if vim.fn.exists('*CocAction') ~= 1 then
    vim.notify('CoC is not ready.', vim.log.levels.ERROR)
    return false
  end
  local ok, result = pcall(vim.fn.CocAction, action, ...)
  if not ok then
    vim.notify('CoC: ' .. tostring(result), vim.log.levels.ERROR)
    return false
  end
  return result ~= false
end

function M.format()
  if ensure_python_buffer() then
    coc_action('format')
  end
end

function M.clean()
  if not ensure_python_buffer() then
    return
  end
  coc_action('runCommand', 'ruff.executeAutofix')
  coc_action('runCommand', 'ruff.executeOrganizeImports')
  coc_action('runCommand', 'ruff.executeFormat')
end

function M.quick_fix()
  if ensure_python_buffer() and vim.fn.exists('*CocActionAsync') == 1 then
    vim.fn.CocActionAsync('doQuickfix')
  end
end

local function escape_status(value)
  return value:gsub('%%', '%%%%')
end

function M.refresh_winbar(win, buf)
  win = win or api.nvim_get_current_win()
  buf = buf or api.nvim_win_get_buf(win)
  if not api.nvim_win_is_valid(win) or not api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.bo[buf].filetype ~= 'python' then
    if vim.w[win].python_pro_winbar then
      vim.wo[win].winbar = vim.w[win].python_pro_previous_winbar or ''
      vim.wo[win].colorcolumn = vim.w[win].python_pro_previous_colorcolumn or ''
      vim.wo[win].foldmethod = vim.w[win].python_pro_previous_foldmethod or 'manual'
      vim.wo[win].foldlevel = vim.w[win].python_pro_previous_foldlevel or 0
      vim.w[win].python_pro_winbar = nil
    end
    return
  end

  if not vim.w[win].python_pro_winbar then
    vim.w[win].python_pro_previous_winbar = vim.wo[win].winbar
    vim.w[win].python_pro_previous_colorcolumn = vim.wo[win].colorcolumn
    vim.w[win].python_pro_previous_foldmethod = vim.wo[win].foldmethod
    vim.w[win].python_pro_previous_foldlevel = vim.wo[win].foldlevel
    vim.w[win].python_pro_winbar = true
  end
  vim.wo[win].colorcolumn = '89'
  vim.wo[win].foldmethod = 'indent'
  vim.wo[win].foldlevel = 99
  local info = venv.resolve(buf)
  local group = info.exists and 'PythonProVenv' or 'PythonProVenvMissing'
  local suffix = info.exists and '' or ' [missing]'
  vim.wo[win].winbar = '%=%#' .. group .. '# Python: ' .. escape_status(info.venv .. suffix) .. ' '
end

local function setup_buffer(buf)
  vim.bo[buf].expandtab = true
  vim.bo[buf].tabstop = 4
  vim.bo[buf].softtabstop = 4
  vim.bo[buf].shiftwidth = 4
  vim.bo[buf].textwidth = 88

  theme.setup_buffer(buf)
  local info = venv.apply_to_coc(buf, true)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    theme.apply(win)
    M.refresh_winbar(win, buf)
  end

  local function map(lhs, rhs, desc)
    vim.keymap.set('n', lhs, rhs, { buffer = buf, silent = true, desc = desc })
  end
  map('<leader>pf', M.format, 'Python: format with Ruff/CoC')
  map('<leader>pF', M.clean, 'Python: fix, organize imports and format')
  map('<leader>pq', M.quick_fix, 'Python: quick fix at cursor')
  vim.keymap.set('n', '<leader>pa', '<Plug>(coc-codeaction-cursor)', {
    buffer = buf,
    silent = true,
    remap = true,
    desc = 'Python: code actions at cursor',
  })
  vim.keymap.set('n', '<leader>pr', '<Plug>(coc-rename)', {
    buffer = buf,
    silent = true,
    remap = true,
    desc = 'Python: rename symbol with CoC',
  })
  map('<leader>pv', function() venv.select(nil, M.refresh_winbar) end, 'Python: select virtual environment')
  map('<leader>pc', function() venv.create(M.refresh_winbar) end, 'Python: create project .venv')
  map('<leader>pi', function() venv.install_tools(M.refresh_winbar) end, 'Python: install/update Ruff')

  if not info.ruff and vim.fn.exepath('ruff') == '' and not warned_about_ruff then
    warned_about_ruff = true
    vim.schedule(function()
      vim.notify('Python Pro: Ruff not found. Use <leader>pi to install it in .venv.', vim.log.levels.WARN)
    end)
  end
end

local function create_commands()
  api.nvim_create_user_command('PythonFormat', M.format, { desc = 'Format Python with Ruff through CoC' })
  api.nvim_create_user_command('PythonClean', M.clean, { desc = 'Fix, organize imports and format Python' })
  api.nvim_create_user_command('PythonQuickFix', M.quick_fix, { desc = 'Apply Python quick fix at cursor' })
  api.nvim_create_user_command('PythonVenvSelect', function(opts)
    venv.select(opts.args, M.refresh_winbar)
  end, { nargs = '?', complete = 'dir', desc = 'Select virtual environment for this Python project' })
  api.nvim_create_user_command('PythonVenvReset', function()
    venv.reset(M.refresh_winbar)
  end, { desc = 'Reset to <project-root>/.venv' })
  api.nvim_create_user_command('PythonVenvCreate', function()
    venv.create(M.refresh_winbar)
  end, { desc = 'Create <project-root>/.venv with python3' })
  api.nvim_create_user_command('PythonToolsInstall', function()
    venv.install_tools(M.refresh_winbar)
  end, { desc = 'Install/update Ruff in the active virtual environment' })
end

function M.setup()
  if vim.g.loaded_python_pro then
    return
  end
  vim.g.loaded_python_pro = true

  theme.setup()
  create_commands()
  local group = api.nvim_create_augroup('PythonPro', { clear = true })
  api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'python',
    callback = function(event)
      setup_buffer(event.buf)
    end,
  })
  api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
    group = group,
    callback = function(event)
      local win = api.nvim_get_current_win()
      local buf = event.buf or api.nvim_win_get_buf(win)
      if api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == 'python' then
        venv.apply_to_coc(buf, true)
      end
      M.refresh_winbar(win, buf)
    end,
  })
end

return M
