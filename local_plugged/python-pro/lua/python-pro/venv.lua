local M = {}

local api = vim.api
local fn = vim.fn
local uv = vim.uv or vim.loop
local config_dir = fn.stdpath('data') .. '/python-pro'
local config_file = config_dir .. '/venvs.json'
local mappings
local active_python

local markers = {
  'pyproject.toml',
  'setup.py',
  'setup.cfg',
  'requirements.txt',
  'Pipfile',
  '.git',
}

local function normalize(path)
  if not path or path == '' then
    return nil
  end
  return vim.fs.normalize(fn.fnamemodify(fn.expand(path), ':p'))
end

local function load_mappings()
  if mappings then
    return mappings
  end
  mappings = {}
  local ok, lines = pcall(fn.readfile, config_file)
  if ok and #lines > 0 then
    local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
    if decoded_ok and type(decoded) == 'table' then
      mappings = decoded
    end
  end
  return mappings
end

local function save_mappings()
  fn.mkdir(config_dir, 'p')
  fn.writefile({ vim.json.encode(load_mappings()) }, config_file)
end

function M.project_root(buf)
  buf = buf or api.nvim_get_current_buf()
  local name = api.nvim_buf_get_name(buf)
  local start = name ~= '' and name or uv.cwd()
  local root = vim.fs.root(start, markers)
  return normalize(root or uv.cwd())
end

local function executable_for(venv)
  if not venv then
    return nil
  end
  local candidates
  if fn.has('win32') == 1 then
    candidates = { venv .. '/Scripts/python.exe', venv .. '/Scripts/python3.exe' }
  else
    candidates = { venv .. '/bin/python3', venv .. '/bin/python' }
  end
  for _, path in ipairs(candidates) do
    if uv.fs_stat(path) then
      return normalize(path)
    end
  end
  return nil
end

local function ruff_for(venv)
  if not venv then
    return nil
  end
  local path = fn.has('win32') == 1 and (venv .. '/Scripts/ruff.exe') or (venv .. '/bin/ruff')
  return uv.fs_stat(path) and normalize(path) or nil
end

function M.resolve(buf)
  local root = M.project_root(buf)
  local configured = load_mappings()[root]
  local venv = normalize(configured or (root .. '/.venv'))
  local python = executable_for(venv)
  return {
    root = root,
    venv = venv,
    python = python,
    ruff = ruff_for(venv),
    exists = python ~= nil,
    configured = configured ~= nil,
  }
end

local function coc_config(section, value)
  -- Calling the autoload function directly also works before CoC has started,
  -- which lets Jedi and Ruff receive the correct interpreter on first launch.
  pcall(fn['coc#config'], section, value)
end

function M.apply_to_coc(buf, restart)
  local info = M.resolve(buf)
  local python = info.python
  if not python then
    python = fn.exepath('python3')
    if python == '' then
      python = fn.exepath('python')
    end
  end
  if not python or python == '' then
    return info
  end

  coc_config('jedi.workspace.environmentPath', python)
  coc_config('ruff.interpreter', { python })
  coc_config('ruff.nativeBinaryPath', info.ruff or fn.exepath('ruff') or '')

  local changed = active_python ~= nil and active_python ~= python
  active_python = python
  if restart and changed and fn.exists(':CocRestart') == 2 then
    vim.schedule(function()
      vim.cmd('silent! CocRestart')
    end)
  end
  return info
end

local function venv_from_input(path)
  path = normalize(path)
  if not path then
    return nil
  end
  local tail = fn.fnamemodify(path, ':t')
  if tail == 'python' or tail == 'python3' or tail == 'python.exe' or tail == 'python3.exe' then
    return normalize(fn.fnamemodify(path, ':h:h'))
  end
  return path
end

function M.select(path, callback)
  local buf = api.nvim_get_current_buf()
  local root = M.project_root(buf)
  local default = load_mappings()[root] or (root .. '/.venv')
  local function commit(value)
    if not value or value == '' then
      return
    end
    local venv = venv_from_input(value)
    if not executable_for(venv) then
      vim.notify('Python executable not found in virtual environment: ' .. venv, vim.log.levels.ERROR)
      return
    end
    load_mappings()[root] = venv
    save_mappings()
    M.apply_to_coc(buf, true)
    if callback then
      callback()
    end
    vim.notify('Python virtual environment: ' .. venv)
  end

  if path and path ~= '' then
    commit(path)
    return
  end
  vim.ui.input({ prompt = 'Path to virtual environment: ', default = default }, commit)
end

function M.reset(callback)
  local buf = api.nvim_get_current_buf()
  local root = M.project_root(buf)
  load_mappings()[root] = nil
  save_mappings()
  M.apply_to_coc(buf, true)
  if callback then
    callback()
  end
  vim.notify('Reset to default: ' .. root .. '/.venv')
end

function M.create(callback)
  local buf = api.nvim_get_current_buf()
  local info = M.resolve(buf)
  local target = info.root .. '/.venv'
  if executable_for(target) then
    vim.notify('.venv already exists: ' .. target)
    return
  end
  local python = fn.exepath('python3')
  if python == '' then
    vim.notify('python3 was not found; cannot create .venv.', vim.log.levels.ERROR)
    return
  end
  vim.notify('Creating ' .. target .. ' ...')
  vim.system({ python, '-m', 'venv', target }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify('Failed to create .venv: ' .. (result.stderr or ''), vim.log.levels.ERROR)
        return
      end
      load_mappings()[info.root] = nil
      save_mappings()
      M.apply_to_coc(buf, true)
      if callback then
        callback()
      end
      vim.notify('.venv created. Use <leader>pi to install Ruff.')
    end)
  end)
end

function M.install_tools(callback)
  local buf = api.nvim_get_current_buf()
  local info = M.resolve(buf)
  if not info.python then
    vim.notify('No virtual environment found. Use <leader>pc to create one or <leader>pv to select one.', vim.log.levels.WARN)
    return
  end
  vim.notify('Installing/updating Ruff in ' .. info.venv .. ' ...')
  vim.system({ info.python, '-m', 'pip', 'install', '--upgrade', 'ruff' }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify('Failed to install Ruff: ' .. (result.stderr or ''), vim.log.levels.ERROR)
        return
      end
      M.apply_to_coc(buf, true)
      if callback then
        callback()
      end
      vim.notify('Ruff is ready for linting, quick fixes and formatting.')
    end)
  end)
end

return M
